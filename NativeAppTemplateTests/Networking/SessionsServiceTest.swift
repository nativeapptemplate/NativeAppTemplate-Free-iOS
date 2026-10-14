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
    /// gets the generic text rather than "[NATIVEAPPTEMPLATE-2001] "
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
        // Without error_message the user gets the generic communication error, worded as
        // decided for iOS and Android (2026-10-14); the status goes to the log only
        #expect(error.codedDescription ==
            "[NATIVEAPPTEMPLATE-2001] Something went wrong while communicating with the server." + " Please try again later.")
        #expect(error.debugDescription.contains("Status: 502"))
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
