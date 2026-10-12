//
//  SessionControllerPermissionsTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// SessionController.fetchPermissions against a local server: the request it sends
/// once the connection is up, and what it copies from the response.
@MainActor
@Suite(.serialized)
struct SessionControllerPermissionsTest {
    let loginRepository = TestLoginRepository()

    private static let shopkeeper = Shopkeeper(
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
    )!

    /// The meta keys PermissionsRequest.handle requires, as the API sends them
    private nonisolated(unsafe) static let meta: [String: Any] = [
        "ios_app_version": 1,
        "should_update_privacy": true,
        "should_update_terms": false,
        "shop_limit_count": 3
    ]

    private func makeSessionController(server: TestHTTPServer) -> SessionController {
        loginRepository.currentShopkeeper = Self.shopkeeper
        return SessionController(
            loginRepository: loginRepository,
            monitorsConnection: false,
            environment: server.client().environment
        )
    }

    @Test
    func goingOnlineFetchesThePermissionsAndCopiesTheMeta() async throws {
        let server = try await TestHTTPServer.start { request in
            request.path.hasSuffix("/shopkeeper/permissions")
                ? TestHTTPServer.json(["data": [], "meta": Self.meta])
                : TestHTTPServer.json([String: Any]())
        }
        defer { server.stop() }
        let sessionController = makeSessionController(server: server)

        sessionController.connectionChanged(to: .online)
        // The first response reassigns shopkeeper before shopLimitCount is set, so its
        // didSet starts a second request; the state is .loaded once that one lands
        await waitUntil { sessionController.didFetchPermissions && sessionController.hasPermissions }

        let request = try #require(server.requests.first)
        // Service's account-scoped path for PermissionsRequest
        #expect(request.path == "/account-1/api/v1/shopkeeper/permissions")
        #expect(request.headers["access-token"] == "token-1")
        #expect(sessionController.sessionState == .online)
        #expect(sessionController.hasPermissions)
        // The values in meta above
        #expect(sessionController.shouldUpdatePrivacy)
        #expect(!sessionController.shouldUpdateTerms)
        #expect(sessionController.shopLimitCount == 3)
    }

    /// End to end: launching with an expired token. The permissions request gets
    /// devise_token_auth's 401, and the app signs out instead of showing
    /// MainView's permissions error screen.
    @Test
    func expiredTokenAtLaunchSignsOut() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json(status: 401, ["errors": ["You need to sign in or sign up before continuing."]])
        }
        defer { server.stop() }
        var shopkeeper = Self.shopkeeper
        // Unique, so the notice can't sign out another test's SessionController
        shopkeeper.token = "expired-\(UUID().uuidString)"
        loginRepository.currentShopkeeper = shopkeeper
        let sessionController = SessionController(
            loginRepository: loginRepository,
            monitorsConnection: false,
            environment: server.client().environment
        )

        sessionController.connectionChanged(to: .online)
        await waitUntil { !sessionController.isLoggedIn }
        // The failed fetch's catch runs after the sign-out; give it time to land
        try await Task.sleep(for: .milliseconds(200))

        #expect(sessionController.didExpireSession)
        #expect(loginRepository.currentShopkeeper == nil)
        #expect(sessionController.permissionState == .notLoaded)
    }

    @Test
    func failedFetchIsAPermissionError() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json(status: 500, ["error_message": "boom"])
        }
        defer { server.stop() }
        let sessionController = makeSessionController(server: server)

        sessionController.connectionChanged(to: .online)
        await waitUntil { sessionController.permissionState == .error }

        #expect(!sessionController.didFetchPermissions)
    }

    /// Offline, nothing is requested
    @Test
    func goingOfflineFetchesNothing() async throws {
        let server = try await TestHTTPServer.start { _ in TestHTTPServer.json([String: Any]()) }
        defer { server.stop() }
        let sessionController = makeSessionController(server: server)

        sessionController.connectionChanged(to: .offline)
        try await Task.sleep(for: .milliseconds(200))

        #expect(sessionController.sessionState == .offline)
        #expect(server.requests.isEmpty)
        #expect(sessionController.permissionState == .notLoaded)
    }
}
