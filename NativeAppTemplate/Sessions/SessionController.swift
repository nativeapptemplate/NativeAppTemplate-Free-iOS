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

    var shouldUpdateApp = false
    var shouldUpdatePrivacy = false
    var shouldUpdateTerms = false
    var shopLimitCount = 0

    var shopkeeper: Shopkeeper? {
        didSet {
            setClient()

            if shopkeeper != nil {
                userState = .loggedIn

                if shopLimitCount == 0 {
                    permissionState = .notLoaded
                    fetchPermissions()
                } else {
                    permissionState = .loaded
                }
            } else {
                userState = .notLoggedIn
                permissionState = .notLoaded
                // URLSession.api keeps no cache, but versions before it used
                // URLCache.shared, which holds their API responses on disk
                URLCache.shared.removeAllCachedResponses()
            }
        }
    }

    private(set) var client: NativeAppTemplateAPI

    private(set) var loginRepository: LoginRepositoryProtocol
    private let environment: NativeAppTemplateEnvironment
    private let connectionMonitor = NWPathMonitor()
    private(set) var permissionsService: PermissionsService
    private(set) var meService: MeService

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
    init(
        loginRepository: LoginRepositoryProtocol,
        monitorsConnection: Bool = true,
        environment: NativeAppTemplateEnvironment = .prod
    ) {
        self.loginRepository = loginRepository
        self.environment = environment

        let shopkeeper = loginRepository.currentShopkeeper
        let client = Self.makeClient(shopkeeper: shopkeeper, environment: environment)
        self.client = client
        permissionsService = .init(networkClient: client)
        meService = .init(networkClient: client)
        setShopkeeper(shopkeeper: shopkeeper)
        if monitorsConnection {
            prepareConnectionMonitor()
        }
    }

    func login(email: String, password: String) async throws {
        guard userState != .loggingIn else { return }

        userState = .loggingIn

        do {
            shopkeeper = try await loginRepository.login(email: email, password: password)
            Event
                .login(from: Self.self)
                .log()
            fetchPermissions()
        } catch {
            userState = .notLoggedIn
            permissionState = .notLoaded

            Failure
                .login(from: Self.self, reason: error.codedDescription)
                .log()

            throw error
        }
    }

    func logout() async throws {
        do {
            shouldPopToRootView = true
            try await loginRepository.logout(networkClient: client)

            userState = .notLoggedIn
            permissionState = .notLoaded
            shopkeeper = nil
        } catch {
            Failure
                .logout(from: Self.self, reason: error.codedDescription)
                .log()

            userState = .notLoggedIn
            permissionState = .notLoaded
            shopkeeper = nil

            throw error
        }
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

                // Update the user
                self.shopkeeper = shopkeeper
                // Ensure loginRepository is aware, and hence the keychain is updated
                try self.loginRepository.updateShopkeeper(shopkeeper: self.shopkeeper)

                shouldUpdateApp = Int(Bundle.main.appBuild)! < permissionsResponse.iosAppVersion
                shouldUpdatePrivacy = permissionsResponse.shouldUpdatePrivacy
                shouldUpdateTerms = permissionsResponse.shouldUpdateTerms
                shopLimitCount = permissionsResponse.shopLimitCount

                didFetchPermissions = true

                await syncLocaleIfNeeded()
            } catch {
                enum Permissions {}
                Failure
                    .fetch(from: Permissions.self, reason: error.codedDescription)
                    .log()

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
                .update(from: Self.self, reason: error.codedDescription)
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
                .update(from: Self.self, reason: error.codedDescription)
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
                .update(from: Self.self, reason: error.codedDescription)
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
