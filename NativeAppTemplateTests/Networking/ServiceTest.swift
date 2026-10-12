//
//  ServiceTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// Service.makeRequest against a local HTTP server
@MainActor
@Suite(.serialized)
struct ServiceTest {
    /// The HTML page has no error_message to show, so the message is nil and the
    /// user gets the generic text, as for a JSON body without error_message.
    /// An empty message would read "[NATIVEAPPTEMPLATE-2001]  [Status: 502]".
    @Test
    func errorStatusWithANonJsonBodyHasNoMessage() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.response(status: 502, body: "<html>Bad Gateway</html>", contentType: "text/html")
        }
        defer { server.stop() }

        let error = try await requestFailed {
            _ = try await ItemTagsService(networkClient: server.client()).itemTagDetail(id: "t1")
        }

        guard case let .requestFailed(_, _, message) = error else {
            Issue.record("Expected requestFailed, got \(error)")
            return
        }
        #expect(message == nil)
        // NativeAppTemplateAPIError.errorDescription without a message and without an underlying error:
        // "NativeAppTemplateAPIError::RequestFailed[Status: \(statusCode) | Error: UNKNOWN]", prefixed with the code
        #expect(error.codedDescription ==
            "[NATIVEAPPTEMPLATE-2001] NativeAppTemplateAPIError::RequestFailed[Status: 502 | Error: UNKNOWN]")
    }
}

/// Runs `body` and returns the NativeAppTemplateAPIError it throws
@MainActor
func requestFailed(_ body: () async throws -> Void) async throws -> NativeAppTemplateAPIError {
    do {
        try await body()
    } catch let error as NativeAppTemplateAPIError {
        return error
    }
    Issue.record("Expected a NativeAppTemplateAPIError")
    throw CancellationError()
}
