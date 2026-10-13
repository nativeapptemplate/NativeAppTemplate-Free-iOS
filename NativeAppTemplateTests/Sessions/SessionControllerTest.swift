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
    @Test
    func signingOutRemovesCachedResponses() async throws {
        let loginRepository = TestLoginRepository()
        loginRepository.currentShopkeeper = try #require(Shopkeeper(
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
        ))
        let sessionController = SessionController(loginRepository: loginRepository, monitorsConnection: false)

        let url = try #require(URL(string: "https://example.com/\(UUID().uuidString)"))
        let request = URLRequest(url: url)
        let response = try #require(HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Cache-Control": "max-age=3600"]
        ))
        URLCache.shared.storeCachedResponse(CachedURLResponse(response: response, data: Data("{}".utf8)), for: request)
        try #require(URLCache.shared.cachedResponse(for: request) != nil)

        try await sessionController.logout()

        #expect(URLCache.shared.cachedResponse(for: request) == nil)
    }

    // MARK: - Expired session

    /// A signed-in SessionController listening on its own NotificationCenter, so
    /// notices from other tests can't reach it
    private func signedInSessionController(
        token: String,
        notificationCenter: NotificationCenter
    ) throws -> (SessionController, TestLoginRepository) {
        let loginRepository = TestLoginRepository()
        loginRepository.currentShopkeeper = try #require(Shopkeeper(
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
        ))
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
}
