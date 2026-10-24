//
//  SessionControllerTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import OSLog
import Testing

@MainActor
@Suite(.serialized)
struct SessionControllerTest {
    /// A failed sign-out is logged as Failure.logout ("Failed_logout"), not as a
    /// sign-in failure. Failure.log writes
    /// "Failed_\(action) source=\(source) reason=\(reason)" to appLogger
    /// (subsystem com.nativeapptemplate), which this process can read back.
    @Test
    func failedLogoutIsLoggedAsALogoutFailure() async throws {
        let loginRepository = TestLoginRepository()
        loginRepository.logoutError = KeychainStoreError.badData
        let sessionController = SessionController(loginRepository: loginRepository, monitorsConnection: false)
        let start = Date.now.addingTimeInterval(-1)

        await #expect(throws: KeychainStoreError.self) {
            try await sessionController.logout()
        }

        let store = try OSLogStore(scope: .currentProcessIdentifier)
        let messages = try store
            .getEntries(
                at: store.position(date: start),
                matching: NSPredicate(format: "subsystem == %@", "com.nativeapptemplate")
            )
            .compactMap { ($0 as? OSLogEntryLog)?.composedMessage }
            .filter { $0.contains("source=SessionController ") }

        #expect(messages.contains { $0.hasPrefix("Failed_logout ") })
        #expect(!messages.contains { $0.hasPrefix("Failed_login ") })
        // The session is still cleared
        #expect(sessionController.userState == .notLoggedIn)
    }

    /// Versions before URLSession.api dropped its cache left API responses in
    /// URLCache.shared (on disk). Ending the session removes them.
    ///
    /// The test uses its own in-memory URLCache. With URLCache.shared it failed now
    /// and then: the shared cache writes stored responses to disk later, on a queue
    /// of its own, so a write could land after removeAllCachedResponses and the
    /// response was there again. Other tests signing out at the same time also
    /// empty the shared cache, between the store and the check that it is there.
    @Test
    func signingOutRemovesCachedResponses() async throws {
        let loginRepository = TestLoginRepository()
        loginRepository.currentShopkeeper = Shopkeeper(
            id: "shopkeeper-1",
            accountId: "account-1",
            personalAccountId: "account-1",
            accountOwnerId: "shopkeeper-1",
            accountName: "Account",
            email: "test@example.com",
            name: "Test User",
            timeZone: "Tokyo",
            locale: "en",
            uid: "test@example.com",
            token: "token-1",
            client: "client-1",
            expiry: "expiry-1"
        )
        let urlCache = URLCache(memoryCapacity: 1_000_000, diskCapacity: 0, directory: nil)
        let sessionController = SessionController(
            loginRepository: loginRepository,
            monitorsConnection: false,
            urlCache: urlCache
        )

        let url = try #require(URL(string: "https://example.com/\(UUID().uuidString)"))
        let request = URLRequest(url: url)
        let response = try #require(HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Cache-Control": "max-age=3600"]
        ))
        urlCache.storeCachedResponse(CachedURLResponse(response: response, data: Data("{}".utf8)), for: request)
        try #require(urlCache.cachedResponse(for: request) != nil)

        try await sessionController.logout()

        #expect(urlCache.cachedResponse(for: request) == nil)
    }

    /// The app's SessionController empties the cache the old versions used
    @Test
    func signOutEmptiesTheSharedCacheByDefault() {
        let sessionController = SessionController(loginRepository: TestLoginRepository(), monitorsConnection: false)

        #expect(sessionController.urlCache === URLCache.shared)
    }

    // MARK: - Expired session

    /// A signed-in SessionController listening on its own NotificationCenter, so
    /// notices from other tests can't reach it
    private func signedInSessionController(
        token: String,
        notificationCenter: NotificationCenter
    ) throws -> (SessionController, TestLoginRepository) {
        let loginRepository = TestLoginRepository()
        loginRepository.currentShopkeeper = Shopkeeper(
            id: "shopkeeper-1",
            accountId: "account-1",
            personalAccountId: "account-1",
            accountOwnerId: "shopkeeper-1",
            accountName: "Account",
            email: "test@example.com",
            name: "Test User",
            timeZone: "Tokyo",
            locale: "en",
            uid: "test@example.com",
            token: token,
            client: "client-1",
            expiry: "expiry-1"
        )
        let sessionController = SessionController(
            loginRepository: loginRepository,
            monitorsConnection: false,
            notificationCenter: notificationCenter
        )
        return (sessionController, loginRepository)
    }

    /// Every request fails once the token has expired, so the app signs out
    /// locally and says why
    @Test
    func expiredTokenSignsOut() throws {
        let notificationCenter = NotificationCenter()
        let (sessionController, loginRepository) = try signedInSessionController(
            token: "token-1",
            notificationCenter: notificationCenter
        )
        #expect(sessionController.isLoggedIn)

        notificationCenter.post(
            name: .apiSessionDidExpire,
            object: nil,
            userInfo: [Notification.authTokenKey: "token-1"]
        )

        #expect(!sessionController.isLoggedIn)
        #expect(sessionController.shopkeeper == nil)
        // The saved session is gone too, so the next launch starts signed out
        #expect(loginRepository.currentShopkeeper == nil)
        #expect(sessionController.didExpireSession)
    }

    /// A 401 for a token this session no longer uses (a request sent before the
    /// user signed in again) is not about the current session
    @Test
    func expiryOfAnotherTokenKeepsTheSession() throws {
        let notificationCenter = NotificationCenter()
        let (sessionController, loginRepository) = try signedInSessionController(
            token: "token-2",
            notificationCenter: notificationCenter
        )

        notificationCenter.post(
            name: .apiSessionDidExpire,
            object: nil,
            userInfo: [Notification.authTokenKey: "old-token"]
        )

        #expect(sessionController.isLoggedIn)
        #expect(loginRepository.currentShopkeeper != nil)
        #expect(!sessionController.didExpireSession)
    }

    // MARK: - State from the saved session (characterization)

    @Test
    func signedOutHasNoSession() {
        let sessionController = SessionController(loginRepository: TestLoginRepository(), monitorsConnection: false)

        #expect(sessionController.userState == .notLoggedIn)
        #expect(!sessionController.isLoggedIn)
        #expect(sessionController.permissionState == .notLoaded)
        #expect(!sessionController.hasPermissions)
        // NWPathMonitor is off, so nothing has reported the connection yet
        #expect(sessionController.sessionState == .unknown)
        // makeClient uses "" for every session field when signed out
        #expect(sessionController.client.authToken.isEmpty)
        #expect(sessionController.client.client.isEmpty)
        #expect(sessionController.client.uid.isEmpty)
        #expect(sessionController.client.accountId.isEmpty)
    }

    /// A saved shopkeeper is signed in, and the client carries its session. The
    /// permissions are not loaded (didFetchPermissions is still false), and the fetch waits
    /// for the connection (sessionState is .unknown until connectionChanged).
    @Test
    func savedShopkeeperIsSignedInAndWaitsForThePermissions() throws {
        let (sessionController, _) = try signedInSessionController(
            token: "token-1",
            notificationCenter: NotificationCenter()
        )

        #expect(sessionController.isLoggedIn)
        #expect(sessionController.permissionState == .notLoaded)
        #expect(!sessionController.hasPermissions)
        // The values signedInSessionController saved
        #expect(sessionController.client.authToken == "token-1")
        #expect(sessionController.client.client == "client-1")
        #expect(sessionController.client.expiry == "expiry-1")
        #expect(sessionController.client.uid == "test@example.com")
        #expect(sessionController.client.accountId == "account-1")
    }

    // MARK: - Signing in

    @Test
    func loginSignsInWithTheReturnedSession() async throws {
        let loginRepository = TestLoginRepository()
        let sessionController = SessionController(loginRepository: loginRepository, monitorsConnection: false)
        sessionController.didExpireSession = true

        try await sessionController.login(email: "a@example.com", password: "secret")

        #expect(loginRepository.loginCalled)
        #expect(sessionController.isLoggedIn)
        #expect(sessionController.shopkeeper?.email == "a@example.com")
        // TestLoginRepository.login's token and account
        #expect(sessionController.client.authToken == "mockToken")
        #expect(sessionController.client.accountId == "mockAccountId")
        // The expired-session notice is about the session that ended
        #expect(!sessionController.didExpireSession)
    }

    @Test
    func failedLoginStaysSignedOutAndRethrows() async {
        let loginRepository = TestLoginRepository()
        loginRepository.loginError = NativeAppTemplateAPIError.requestFailed(nil, 401, "Invalid login credentials")
        let sessionController = SessionController(loginRepository: loginRepository, monitorsConnection: false)

        await #expect(throws: NativeAppTemplateAPIError.self) {
            try await sessionController.login(email: "a@example.com", password: "wrong")
        }

        #expect(sessionController.userState == .notLoggedIn)
        #expect(sessionController.permissionState == .notLoaded)
        #expect(sessionController.shopkeeper == nil)
    }

    // MARK: - Signing out

    @Test
    func logoutSignsOutAndPopsToRoot() async throws {
        let (sessionController, loginRepository) = try signedInSessionController(
            token: "token-1",
            notificationCenter: NotificationCenter()
        )

        try await sessionController.logout()

        #expect(loginRepository.logoutCalled)
        #expect(sessionController.shouldPopToRootView)
        #expect(sessionController.userState == .notLoggedIn)
        #expect(sessionController.permissionState == .notLoaded)
        #expect(sessionController.shopkeeper == nil)
        #expect(sessionController.client.authToken.isEmpty)
        // A sign-out the user asked for is not an expired session
        #expect(!sessionController.didExpireSession)
    }

    /// The API call fails while signed in: the error reaches the caller, but the
    /// session is cleared anyway and the app pops to root
    @Test
    func failedLogoutStillSignsOut() async throws {
        let (sessionController, loginRepository) = try signedInSessionController(
            token: "token-1",
            notificationCenter: NotificationCenter()
        )
        loginRepository.logoutError = NativeAppTemplateAPIError.requestFailed(nil, 500, nil)

        await #expect(throws: NativeAppTemplateAPIError.self) {
            try await sessionController.logout()
        }

        #expect(sessionController.shouldPopToRootView)
        #expect(sessionController.userState == .notLoggedIn)
        #expect(sessionController.permissionState == .notLoaded)
        #expect(sessionController.shopkeeper == nil)
        #expect(sessionController.client.authToken.isEmpty)
    }

    /// updateShopkeeper(nil) clears the saved session and signs out, without popping to root
    @Test
    func updatingTheShopkeeperToNilSignsOut() throws {
        let (sessionController, loginRepository) = try signedInSessionController(
            token: "token-1",
            notificationCenter: NotificationCenter()
        )

        try sessionController.updateShopkeeper(shopkeeper: nil)

        #expect(!sessionController.isLoggedIn)
        #expect(loginRepository.currentShopkeeper == nil)
        #expect(sessionController.client.authToken.isEmpty)
        #expect(!sessionController.shouldPopToRootView)
    }

    /// updateShopkeeper saves the new shopkeeper and points the client at its session
    @Test
    func updatingTheShopkeeperSavesItAndUpdatesTheClient() throws {
        let (sessionController, loginRepository) = try signedInSessionController(
            token: "token-1",
            notificationCenter: NotificationCenter()
        )
        var shopkeeper = try #require(sessionController.shopkeeper)
        shopkeeper.name = "Renamed"
        shopkeeper.token = "token-2"

        try sessionController.updateShopkeeper(shopkeeper: shopkeeper)

        #expect(loginRepository.updateShopkeeperCalled)
        #expect(loginRepository.currentShopkeeper?.name == "Renamed")
        #expect(sessionController.shopkeeper?.name == "Renamed")
        #expect(sessionController.client.authToken == "token-2")
        #expect(sessionController.isLoggedIn)
    }

    /// sessionDidExpire needs a token, and only acts while signed in
    @Test
    func expiryWithoutATokenOrWhenSignedOutDoesNothing() throws {
        let (signedIn, loginRepository) = try signedInSessionController(
            token: "token-1",
            notificationCenter: NotificationCenter()
        )
        signedIn.sessionDidExpire(authToken: nil)

        #expect(signedIn.isLoggedIn)
        #expect(loginRepository.currentShopkeeper != nil)
        #expect(!signedIn.didExpireSession)

        let signedOut = SessionController(loginRepository: TestLoginRepository(), monitorsConnection: false)
        // A signed-out client's token is "", so this would match it if not for the isLoggedIn guard
        signedOut.sessionDidExpire(authToken: "")

        #expect(!signedOut.didExpireSession)
        #expect(!signedOut.shouldPopToRootView)
    }
}
