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
        "should_update_terms": false
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
    }

    /// Going online asks for the permissions once. The response used to be applied
    /// by reassigning shopkeeper, whose didSet still saw them unfetched and sent
    /// a second request (and synced the locale twice).
    @Test
    func permissionsAreFetchedOnce() async throws {
        let server = try await TestHTTPServer.start { request in
            request.path.hasSuffix("/shopkeeper/permissions")
                ? TestHTTPServer.json(["data": [], "meta": Self.meta])
                : TestHTTPServer.json([String: Any]())
        }
        defer { server.stop() }
        let sessionController = makeSessionController(server: server)

        sessionController.connectionChanged(to: .online)
        await waitUntil { sessionController.hasPermissions }
        // A second request would be sent as the first response is applied; give it time to arrive
        try await Task.sleep(for: .milliseconds(500))

        #expect(server.requests.filter { $0.path.hasSuffix("/shopkeeper/permissions") }.count == 1)
    }

    /// Signing out forgets the permissions of the shopkeeper who left. Otherwise the
    /// next sign-in starts with them: its didSet saw them fetched and marked the
    /// permissions loaded, so the previous shopkeeper's privacy prompt showed.
    @Test
    func signingOutForgetsThePermissions() async throws {
        let server = try await TestHTTPServer.start { request in
            request.path.hasSuffix("/shopkeeper/permissions")
                ? TestHTTPServer.json(["data": [], "meta": Self.meta])
                : TestHTTPServer.json([String: Any]())
        }
        defer { server.stop() }
        let sessionController = makeSessionController(server: server)
        sessionController.connectionChanged(to: .online)
        await waitUntil { sessionController.hasPermissions }
        // From meta above
        try #require(sessionController.shouldUpdatePrivacy)

        try await sessionController.logout()

        // Nothing is known without a session: the properties' initial values
        #expect(!sessionController.shouldUpdatePrivacy)
        #expect(!sessionController.shouldUpdateTerms)
        #expect(!sessionController.shouldUpdateApp)
        #expect(!sessionController.didFetchPermissions)
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

    /// Once the permissions are loaded, the next connection change does not ask
    /// again (fetchPermissionsIfNeeded)
    @Test
    func goingOnlineAgainKeepsTheLoadedPermissions() async throws {
        let server = try await TestHTTPServer.start { request in
            request.path.hasSuffix("/shopkeeper/permissions")
                ? TestHTTPServer.json(["data": [], "meta": Self.meta])
                : TestHTTPServer.json([String: Any]())
        }
        defer { server.stop() }
        let sessionController = makeSessionController(server: server)
        sessionController.connectionChanged(to: .online)
        await waitUntil { sessionController.didFetchPermissions }

        sessionController.connectionChanged(to: .offline)
        sessionController.connectionChanged(to: .online)
        // A second request would be sent at once; give it time to arrive
        try await Task.sleep(for: .milliseconds(500))

        #expect(server.requests.filter { $0.path.hasSuffix("/shopkeeper/permissions") }.count == 1)
        #expect(sessionController.hasPermissions)
    }

    /// shouldUpdateApp: the API's ios_app_version is newer than this build's
    /// CFBundleVersion (`Int(appBuild) < iosAppVersion`)
    @Test(arguments: [(1, true), (0, false)])
    func newerAppVersionAsksForAnUpdate(versionsAhead: Int, shouldUpdateApp: Bool) async throws {
        let build = try #require(Int(Bundle.main.appBuild))
        var meta = Self.meta
        meta["ios_app_version"] = build + versionsAhead
        nonisolated(unsafe) let responseMeta = meta
        let server = try await TestHTTPServer.start { request in
            request.path.hasSuffix("/shopkeeper/permissions")
                ? TestHTTPServer.json(["data": [], "meta": responseMeta])
                : TestHTTPServer.json([String: Any]())
        }
        defer { server.stop() }
        let sessionController = makeSessionController(server: server)

        sessionController.connectionChanged(to: .online)
        await waitUntil { sessionController.didFetchPermissions }

        #expect(sessionController.shouldUpdateApp == shouldUpdateApp)
    }

    // MARK: - Locale sync

    /// The saved shopkeeper's locale differs from the app's language (tests run in
    /// English): after the permissions, SignUpsService.updateLocale PATCHes
    /// /shopkeeper_auth (devise_token_auth's root path) and the new locale is saved
    @Test
    func aDifferentLocaleIsSyncedAfterThePermissions() async throws {
        let server = try await TestHTTPServer.start { request in
            request.path.hasSuffix("/shopkeeper/permissions")
                ? TestHTTPServer.json(["data": [], "meta": Self.meta])
                : TestHTTPServer.json([String: Any]())
        }
        defer { server.stop() }
        var shopkeeper = Self.shopkeeper
        shopkeeper.locale = "ja"
        loginRepository.currentShopkeeper = shopkeeper
        let sessionController = SessionController(
            loginRepository: loginRepository,
            monitorsConnection: false,
            environment: server.client().environment
        )

        sessionController.connectionChanged(to: .online)
        await waitUntil { sessionController.shopkeeper?.locale == "en" }

        let request = try #require(server.requests.first { $0.path == "/shopkeeper_auth" })
        #expect(request.method == "PATCH")
        #expect(request.headers["access-token"] == "token-1")
        #expect(try JSONSerialization.jsonObject(with: request.body) as? [String: String] == ["locale": "en"])
        #expect(loginRepository.currentShopkeeper?.locale == "en")
    }

    /// The locale sync goes through RootPathService, which, unlike Service, does not
    /// announce devise_token_auth's 401 as an expired session: a rejected token
    /// there keeps the session, and the locale stays as it was for the next try
    @Test
    func rejectedLocaleSyncKeepsTheSession() async throws {
        let server = try await TestHTTPServer.start { request in
            request.path.hasSuffix("/shopkeeper/permissions")
                ? TestHTTPServer.json(["data": [], "meta": Self.meta])
                : TestHTTPServer.json(status: 401, ["errors": ["You need to sign in or sign up before continuing."]])
        }
        defer { server.stop() }
        var shopkeeper = Self.shopkeeper
        shopkeeper.locale = "ja"
        // Unique, so a notice can't sign out another test's SessionController
        shopkeeper.token = "rejected-\(UUID().uuidString)"
        loginRepository.currentShopkeeper = shopkeeper
        let sessionController = SessionController(
            loginRepository: loginRepository,
            monitorsConnection: false,
            environment: server.client().environment
        )

        sessionController.connectionChanged(to: .online)
        await waitUntil { server.requests.contains { $0.path == "/shopkeeper_auth" } }
        // The failed sync's catch runs after the response; give it time to land
        try await Task.sleep(for: .milliseconds(200))

        #expect(sessionController.isLoggedIn)
        #expect(!sessionController.didExpireSession)
        #expect(sessionController.shopkeeper?.locale == "ja")
        #expect(sessionController.hasPermissions)
    }

    // MARK: - Privacy policy and terms

    @Test
    func confirmingPrivacyAndTermsPatchesMeAndClearsTheFlags() async throws {
        let server = try await TestHTTPServer.start { _ in TestHTTPServer.json(["status": 200]) }
        defer { server.stop() }
        let sessionController = makeSessionController(server: server)
        sessionController.shouldUpdatePrivacy = true
        sessionController.shouldUpdateTerms = true

        try await sessionController.updateConfirmedPrivacyVersion()
        try await sessionController.updateConfirmedTermsVersion()

        #expect(!sessionController.shouldUpdatePrivacy)
        #expect(!sessionController.shouldUpdateTerms)
        // MeRequest.swift: PATCH /shopkeeper/me/update_confirmed_{privacy,terms}_version,
        // under Service's /{accountId}/api/v1 (account-1 above)
        #expect(server.requests.map(\.method) == ["PATCH", "PATCH"])
        #expect(server.requests.map(\.path) == [
            "/account-1/api/v1/shopkeeper/me/update_confirmed_privacy_version",
            "/account-1/api/v1/shopkeeper/me/update_confirmed_terms_version"
        ])
    }

    /// A failed confirmation keeps asking: the flag stays set and the error reaches the caller
    @Test
    func failedConfirmationKeepsTheFlags() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json(status: 500, ["error_message": "boom"])
        }
        defer { server.stop() }
        let sessionController = makeSessionController(server: server)
        sessionController.shouldUpdatePrivacy = true
        sessionController.shouldUpdateTerms = true

        await #expect(throws: NativeAppTemplateAPIError.self) {
            try await sessionController.updateConfirmedPrivacyVersion()
        }
        await #expect(throws: NativeAppTemplateAPIError.self) {
            try await sessionController.updateConfirmedTermsVersion()
        }

        #expect(sessionController.shouldUpdatePrivacy)
        #expect(sessionController.shouldUpdateTerms)
    }
}
