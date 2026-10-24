//
//  SessionController.swift
//  NativeAppTemplate
//

import Foundation
import Network
import Observation

@MainActor @Observable class SessionController: SessionControllerProtocol {
    // Managing the state of the current session
    private(set) var sessionState: SessionState = .unknown
    private(set) var userState: UserState = .notLoggedIn
    private(set) var permissionState: PermissionState = .notLoaded
    private(set) var didFetchPermissions = false
    var shouldPopToRootView = false
    /// Set when the API rejected the session's token and the app signed out
    var didExpireSession = false

    var shouldUpdateApp = false
    var shouldUpdatePrivacy = false
    var shouldUpdateTerms = false

    var shopkeeper: Shopkeeper? {
        didSet {
            setClient()

            if shopkeeper != nil {
                userState = .loggedIn

                if !didFetchPermissions {
                    permissionState = .notLoaded
                    fetchPermissions()
                } else {
                    permissionState = .loaded
                }
            } else {
                userState = .notLoggedIn
                permissionState = .notLoaded
                // These were the signed-out shopkeeper's; the next one's are fetched
                // on sign-in, so none of them may show meanwhile
                didFetchPermissions = false
                shouldUpdateApp = false
                shouldUpdatePrivacy = false
                shouldUpdateTerms = false
                // URLSession.api keeps no cache, but versions before it used
                // URLCache.shared, which holds their API responses on disk
                urlCache.removeAllCachedResponses()
            }
        }
    }

    private(set) var client: NativeAppTemplateAPI

    private(set) var loginRepository: LoginRepositoryProtocol
    private let environment: NativeAppTemplateEnvironment
    private let connectionMonitor = NWPathMonitor()
    private(set) var permissionsService: PermissionsService
    private(set) var meService: MeService
    private let notificationCenter: NotificationCenter
    /// Emptied on sign-out; URLCache.shared outside tests
    let urlCache: URLCache
    /// Removed in deinit, which is nonisolated
    @ObservationIgnored private nonisolated(unsafe) var sessionExpiryObserver: (any NSObjectProtocol)?

    var isLoggedIn: Bool {
        userState == .loggedIn
    }

    var hasPermissions: Bool {
        if case .loaded = permissionState {
            return true
        }
        return false
    }

    // MARK: - Initializers

    /// - Parameters:
    ///   - monitorsConnection: Starts `NWPathMonitor`; tests pass `false` and call
    ///     `connectionChanged(to:)` themselves, so no permission requests go out on their own.
    ///   - environment: The API the client talks to. Tests point it at a local server.
    ///   - notificationCenter: Where `Service` announces `.apiSessionDidExpire`
    ///   - urlCache: The cache emptied on sign-out. Tests pass their own, so another
    ///     test's sign-out can't empty it meanwhile.
    init(
        loginRepository: LoginRepositoryProtocol,
        monitorsConnection: Bool = true,
        environment: NativeAppTemplateEnvironment = .prod,
        notificationCenter: NotificationCenter = .default,
        urlCache: URLCache = .shared
    ) {
        self.loginRepository = loginRepository
        self.environment = environment
        self.notificationCenter = notificationCenter
        self.urlCache = urlCache

        let shopkeeper = loginRepository.currentShopkeeper
        let client = Self.makeClient(shopkeeper: shopkeeper, environment: environment)
        self.client = client
        permissionsService = .init(networkClient: client)
        meService = .init(networkClient: client)
        setShopkeeper(shopkeeper: shopkeeper)
        if monitorsConnection {
            prepareConnectionMonitor()
        }

        // Service posts on the main actor, and a nil queue runs this at once, so the
        // session is gone before the failed request's caller sees its error
        sessionExpiryObserver = notificationCenter.addObserver(
            forName: .apiSessionDidExpire,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            let authToken = notification.userInfo?[Notification.authTokenKey] as? String
            MainActor.assumeIsolated {
                self?.sessionDidExpire(authToken: authToken)
            }
        }
    }

    deinit {
        if let sessionExpiryObserver {
            notificationCenter.removeObserver(sessionExpiryObserver)
        }
    }

    func login(email: String, password: String) async throws {
        guard userState != .loggingIn else { return }

        userState = .loggingIn

        do {
            shopkeeper = try await loginRepository.login(email: email, password: password)
            didExpireSession = false
            Event
                .login(from: Self.self)
                .log()
            fetchPermissions()
        } catch {
            userState = .notLoggedIn
            permissionState = .notLoaded

            Failure
                .login(from: Self.self, reason: error.debugCodedDescription)
                .log()

            throw error
        }
    }

    func logout() async throws {
        shouldPopToRootView = true
        // Signed out here even when the API call fails; shopkeeper's didSet resets
        // userState and permissionState
        defer { shopkeeper = nil }

        do {
            try await loginRepository.logout(networkClient: client)
        } catch {
            Failure
                .logout(from: Self.self, reason: error.debugCodedDescription)
                .log()
            throw error
        }
    }

    /// The API rejected `authToken` (see `.apiSessionDidExpire`). When that is this
    /// session's token, every further request would fail too, so sign out here: the
    /// server has no session left to destroy, and the user signs in again.
    func sessionDidExpire(authToken: String?) {
        guard isLoggedIn, let authToken, authToken == client.authToken else { return }

        Failure
            .logout(from: Self.self, reason: "The API rejected the session's token")
            .log()

        shouldPopToRootView = true
        try? loginRepository.updateShopkeeper(shopkeeper: nil)
        shopkeeper = nil
        didExpireSession = true
    }

    func fetchPermissionsIfNeeded() {
        guard !hasPermissions else { return }

        fetchPermissions()
    }

    func fetchPermissions() {
        // If there's no connection, use the persisted permissions
        // The re-fetch/re-store will be done the next time they open the app
        guard sessionState == .online else { return }

        // Don't repeatedly make the same request
        if case .loading = permissionState {
            return
        }

        // No point in requesting permissions when there's no user
        guard isLoggedIn else { return }

        permissionState = .loading

        Task {
            do {
                let permissionsResponse = try await permissionsService.allPermissions()

                // Check that we have a logged in user. Otherwise this is pointless
                guard let shopkeeper = self.shopkeeper else { return }

                // Ensure loginRepository is aware, and hence the keychain is updated
                try self.loginRepository.updateShopkeeper(shopkeeper: shopkeeper)

                shouldUpdateApp = Int(Bundle.main.appBuild)! < permissionsResponse.iosAppVersion
                shouldUpdatePrivacy = permissionsResponse.shouldUpdatePrivacy
                shouldUpdateTerms = permissionsResponse.shouldUpdateTerms
                // Set here, not by reassigning shopkeeper: its didSet saw
                // didFetchPermissions still false and requested them again
                permissionState = .loaded

                didFetchPermissions = true

                await syncLocaleIfNeeded()
            } catch {
                enum Permissions {}
                Failure
                    .fetch(from: Permissions.self, reason: error.debugCodedDescription)
                    .log()

                // An expired session has signed out already; that is not a permissions error
                guard isLoggedIn else { return }

                self.permissionState = .error
            }
        }
    }

    /// shopkeepers.locale follows the app's language. Changing that in iOS
    /// Settings relaunches the app, and permissions are fetched on every launch
    /// and sign-in, so syncing after them catches every change. A failure is
    /// retried on the next fetch.
    private func syncLocaleIfNeeded() async {
        guard let locale = shopkeeper?.localeToSync(appLocale: Shopkeeper.appLocale()) else { return }

        do {
            try await SignUpsService(networkClient: client).updateLocale(locale)
            guard var shopkeeper else { return }

            shopkeeper.locale = locale
            try updateShopkeeper(shopkeeper: shopkeeper)
        } catch {
            Failure
                .update(from: Self.self, reason: error.debugCodedDescription)
                .log()
        }
    }

    func updateShopkeeper(shopkeeper: Shopkeeper?) throws {
        try loginRepository.updateShopkeeper(shopkeeper: shopkeeper)
        self.shopkeeper = shopkeeper
    }

    func updateConfirmedPrivacyVersion() async throws {
        do {
            try await meService.updateConfirmedPrivacyVersion()
            shouldUpdatePrivacy = false
        } catch {
            Failure
                .update(from: Self.self, reason: error.debugCodedDescription)
                .log()
            throw error
        }
    }

    func updateConfirmedTermsVersion() async throws {
        do {
            try await meService.updateConfirmedTermsVersion()
            shouldUpdateTerms = false
        } catch {
            Failure
                .update(from: Self.self, reason: error.debugCodedDescription)
                .log()
            throw error
        }
    }

    private func prepareConnectionMonitor() {
        connectionMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.connectionChanged(to: path.status == .satisfied ? .online : .offline)
            }
        }
        connectionMonitor.start(queue: .main)
    }

    /// Called by the connection monitor; internal so tests can go online without it
    func connectionChanged(to newState: SessionState) {
        if newState != sessionState {
            sessionState = newState
        }

        if didFetchPermissions {
            fetchPermissionsIfNeeded()
        } else {
            fetchPermissions()
        }
    }

    /// https://stackoverflow.com/a/25231068/1160200
    private func setShopkeeper(shopkeeper: Shopkeeper?) {
        self.shopkeeper = shopkeeper
    }

    private func setClient() {
        client = Self.makeClient(shopkeeper: shopkeeper, environment: environment)
        permissionsService = PermissionsService(networkClient: client)
        meService = MeService(networkClient: client)
    }

    /// The API client for `shopkeeper`'s session, or one without a session when signed out
    private static func makeClient(
        shopkeeper: Shopkeeper?,
        environment: NativeAppTemplateEnvironment
    ) -> NativeAppTemplateAPI {
        NativeAppTemplateAPI(
            environment: environment,
            authToken: shopkeeper?.token ?? "",
            client: shopkeeper?.client ?? "",
            expiry: shopkeeper?.expiry ?? "",
            uid: shopkeeper?.uid ?? "",
            accountId: shopkeeper?.accountId ?? ""
        )
    }
}
