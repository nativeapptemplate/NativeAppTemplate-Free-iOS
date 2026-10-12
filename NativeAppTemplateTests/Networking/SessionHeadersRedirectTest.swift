//
//  SessionHeadersRedirectTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// URLSession copies custom request headers to every redirect hop, whichever host it goes to.
/// The devise_token_auth headers `Service.makeRequest` adds are a full session, so a
/// redirect away from the API must not carry them.
@Suite(.serialized)
struct SessionHeadersRedirectTest {
    /// The headers Service, SessionsService and SignUpsService add from NativeAppTemplateAPI
    private static let sessionHeaders = ["access-token", "token-type", "client", "expiry", "uid"]

    @Test
    func redirectToAnotherHostDropsSessionHeaders() async throws {
        let target = try await TestHTTPServer.start { _ in TestHTTPServer.response(status: 200) }
        defer { target.stop() }
        // 127.0.0.1 plays the API; the redirect goes to localhost, another host name
        let api = try await TestHTTPServer.start { _ in
            "HTTP/1.1 302 Found\r\nLocation: http://localhost:\(target.port)/elsewhere\r\nContent-Length: 0\r\n\r\n"
        }
        defer { api.stop() }

        let received = try await requestThroughRedirect(apiPort: api.port, target: target)

        for header in Self.sessionHeaders {
            #expect(received[header] == nil, "\(header) leaked to another host")
        }
        // Headers that are not part of the session still go along
        #expect(received["source"] == "ios")
    }

    @Test
    func redirectWithinTheApiHostKeepsSessionHeaders() async throws {
        let target = try await TestHTTPServer.start { _ in TestHTTPServer.response(status: 200) }
        defer { target.stop() }
        let api = try await TestHTTPServer.start { _ in
            "HTTP/1.1 302 Found\r\nLocation: http://127.0.0.1:\(target.port)/moved\r\nContent-Length: 0\r\n\r\n"
        }
        defer { api.stop() }

        let received = try await requestThroughRedirect(apiPort: api.port, target: target)

        // Values set in requestThroughRedirect
        #expect(received["access-token"] == "token")
        #expect(received["client"] == "client")
        #expect(received["uid"] == "uid")
    }

    private func requestThroughRedirect(apiPort: UInt16, target: TestHTTPServer) async throws -> [String: String] {
        let session = URLSession(
            configuration: .ephemeral,
            delegate: APISessionDelegate(apiHost: "127.0.0.1"),
            delegateQueue: nil
        )
        defer { session.invalidateAndCancel() }

        var request = URLRequest(url: URL(string: "http://127.0.0.1:\(apiPort)/api")!)
        for (name, value) in [
            ("access-token", "token"), ("token-type", "Bearer"), ("client", "client"),
            ("expiry", "expiry"), ("uid", "uid"), ("source", "ios")
        ] {
            request.addValue(value, forHTTPHeaderField: name)
        }
        _ = try await session.data(for: request)

        return try #require(target.lastRequestHeaders)
    }
}
