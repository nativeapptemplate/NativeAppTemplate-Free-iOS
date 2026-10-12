//
//  SessionsServiceTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// SessionsService against a local HTTP server
@MainActor
@Suite(.serialized)
struct SessionsServiceTest {
    /// As in ServiceTest: an HTML error page has no error_message, so the user
    /// gets the generic text rather than "[NATIVEAPPTEMPLATE-2001]  [Status: 502]"
    @Test
    func errorStatusWithANonJsonBodyHasNoMessage() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.response(status: 502, body: "<html>Bad Gateway</html>", contentType: "text/html")
        }
        defer { server.stop() }

        let error = try await requestFailed {
            _ = try await SessionsService(networkClient: server.client())
                .makeSession(email: "a@example.com", password: "password")
        }

        guard case let .requestFailed(_, _, message) = error else {
            Issue.record("Expected requestFailed, got \(error)")
            return
        }
        #expect(message == nil)
        // NativeAppTemplateAPIError.errorDescription without a message or underlying error
        #expect(error.codedDescription ==
            "[NATIVEAPPTEMPLATE-2001] NativeAppTemplateAPIError::RequestFailed[Status: 502 | Error: UNKNOWN]")
    }

    /// A sign-in response without data is a processing error (NATIVEAPPTEMPLATE-2002,
    /// NativeAppTemplateAPIError.processingError's code), not a crash
    @Test
    func signInResponseWithoutDataIsAProcessingError() async throws {
        let server = try await TestHTTPServer.start { _ in TestHTTPServer.json([String: Any]()) }
        defer { server.stop() }

        let error = try await requestFailed {
            _ = try await SessionsService(networkClient: server.client())
                .makeSession(email: "a@example.com", password: "password")
        }

        #expect(error.errorCode == "NATIVEAPPTEMPLATE-2002")
    }
}
