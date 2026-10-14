//
//  SignUpsServiceTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
struct SignUpsServiceTest {
    let client = NativeAppTemplateAPI(
        authToken: "token",
        client: "client",
        expiry: "expiry",
        uid: "uid",
        accountId: "account-id"
    )

    /// devise_token_auth's routes sit at the root, without the account and
    /// /api/v1 prefix that Service adds (SessionController syncs the locale)
    @Test
    func updateLocaleRequestPatchesShopkeeperAuthWithOnlyTheLocale() throws {
        let urlRequest = try SignUpsService(networkClient: client).prepare(request: UpdateLocaleRequest(locale: "ja"))

        #expect(urlRequest.url == client.environment.baseURL.appendingPathComponent("/shopkeeper_auth"))
        #expect(urlRequest.httpMethod == "PATCH")
        let body = try #require(urlRequest.httpBody)
        #expect(try JSONSerialization.jsonObject(with: body) as? [String: String] == ["locale": "ja"])
        #expect(urlRequest.value(forHTTPHeaderField: "access-token") == "token")
    }

    /// As in ServiceTest: an HTML error page has no error_message, so the user
    /// gets the generic text rather than "[NATIVEAPPTEMPLATE-2001] "
    @Test
    func errorStatusWithANonJsonBodyHasNoMessage() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.response(status: 502, body: "<html>Bad Gateway</html>", contentType: "text/html")
        }
        defer { server.stop() }

        let error = try await requestFailed {
            _ = try await SignUpsService(networkClient: server.client()).updateLocale("ja")
        }

        guard case let .requestFailed(_, _, message) = error else {
            Issue.record("Expected requestFailed, got \(error)")
            return
        }
        #expect(message == nil)
        // Without error_message the user gets the generic communication error, worded as
        // decided for iOS and Android (2026-10-14); the status goes to the log only
        #expect(error.codedDescription ==
            "[NATIVEAPPTEMPLATE-2001] Something went wrong while communicating with the server." + " Please try again later.")
        #expect(error.debugDescription.contains("Status: 502"))
    }
}
