//
//  RootPathServicesTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// SessionsService and SignUpsService call devise_token_auth's routes, which sit at the
/// API root without the account and /api/v1 prefix that Service adds. Signed out, the
/// client has no token, so they send no session headers at all.
@MainActor
@Suite(.serialized)
struct RootPathServicesTest {
    private static let sessionHeaderNames = ["access-token", "token-type", "client", "expiry", "uid"]

    private func signedOut(_ server: TestHTTPServer) -> NativeAppTemplateAPI {
        NativeAppTemplateAPI(
            // NativeAppTemplateEnvironment.swift is also compiled into the test target
            environment: NativeAppTemplate.NativeAppTemplateEnvironment(
                baseURL: URL(string: "http://127.0.0.1:\(server.port)")!
            ),
            authToken: "",
            client: "",
            expiry: "",
            uid: "",
            accountId: "account-id"
        )
    }

    /// A shopkeeper resource as ShopkeeperSignInAdapter reads it
    private nonisolated static let signInBody: [String: Any] = [
        "data": [
            "id": "s1",
            "type": "shopkeeper_sign_in",
            "attributes": [
                "account_id": "a1",
                "personal_account_id": "a1",
                "account_owner_id": "s1",
                "account_name": "Account",
                "email": "a@example.com",
                "name": "Name",
                "time_zone": "Tokyo",
                "token": "new-token",
                "client": "new-client",
                "uid": "a@example.com",
                "expiry": "1"
            ] as [String: Any]
        ] as [String: Any]
    ]

    @Test
    func sessionsServiceSignInGoesToTheRootPathWithoutSessionHeadersWhenSignedOut() async throws {
        let server = try await TestHTTPServer.start { _ in TestHTTPServer.json(Self.signInBody) }
        defer { server.stop() }

        _ = try? await SessionsService(networkClient: signedOut(server))
            .makeSession(email: "a@example.com", password: "secret")

        let request = try #require(server.requests.first)
        // MakeSessionRequest.path, appended to the bare base URL (no account, no /api/v1)
        #expect(request.path == "/shopkeeper_auth/sign_in")
        #expect(request.method == "POST")
        for name in Self.sessionHeaderNames {
            #expect(request.headers[name] == nil, "\(name) sent while signed out")
        }
        #expect(request.headers["source"] == "ios")
        #expect(request.headers["content-type"] == "application/json")
        let json = try #require(try JSONSerialization.jsonObject(with: request.body) as? [String: String])
        #expect(json == ["email": "a@example.com", "password": "secret"])
    }

    @Test
    func sessionsServiceSignOutSendsTheSessionHeaders() async throws {
        let server = try await TestHTTPServer.start { _ in TestHTTPServer.json([String: Any]()) }
        defer { server.stop() }

        try await SessionsService(networkClient: server.client()).destroySession()

        let request = try #require(server.requests.first)
        #expect(request.path == "/shopkeeper_auth/sign_out")
        #expect(request.method == "DELETE")
        // The values TestHTTPServer.client sets
        #expect(request.headers["access-token"] == "token")
        #expect(request.headers["token-type"] == "Bearer")
        #expect(request.headers["client"] == "client")
        #expect(request.headers["expiry"] == "expiry")
        #expect(request.headers["uid"] == "uid")
        // setValue after the headers: one value, not "ios,ios"
        #expect(request.headers["source"] == "ios")
        #expect(request.headers["content-type"] == "application/json")
    }

    @Test
    func signUpsServiceSendsNoSessionHeadersWhenSignedOut() async throws {
        let server = try await TestHTTPServer.start { _ in TestHTTPServer.json([String: Any]()) }
        defer { server.stop() }

        let urlRequest = try SignUpsService(networkClient: signedOut(server)).prepare(
            request: SendResetPasswordInstructionRequest(sendResetPassword: SendResetPassword(email: "a@example.com"))
        )

        #expect(urlRequest.url?.path == "/shopkeeper_auth/password")
        for name in Self.sessionHeaderNames {
            #expect(urlRequest.value(forHTTPHeaderField: name) == nil, "\(name) sent while signed out")
        }
        #expect(urlRequest.value(forHTTPHeaderField: "source") == "ios")
        #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    /// The API's error_message and the status become requestFailed, as in Service
    @Test
    func errorStatusWithErrorMessageBecomesRequestFailedWithThatMessage() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json(status: 401, ["error_message": "Invalid login credentials"])
        }
        defer { server.stop() }

        let error = try await requestFailed {
            _ = try await SessionsService(networkClient: server.client())
                .makeSession(email: "a@example.com", password: "wrong")
        }

        guard case let .requestFailed(_, statusCode, message) = error else {
            Issue.record("Expected requestFailed, got \(error)")
            return
        }
        #expect(statusCode == 401)
        #expect(message == "Invalid login credentials")
        // server.client() is signed in, so the session headers go along
        #expect(server.requests.first?.headers["access-token"] == "token")
    }
}
