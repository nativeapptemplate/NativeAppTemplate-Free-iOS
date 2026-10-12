//
//  APISessionStorageTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// API responses hold the shopkeeper's data, so `URLSession.api` must not keep
/// them in a URL cache (on disk in Library/Caches, past sign-out), and it must not
/// keep cookies: the API authenticates with the devise_token_auth headers only.
@Suite(.serialized)
struct APISessionStorageTest {
    /// The cache headers Rails puts on a 200 JSON response (Rack::ETag sets
    /// "max-age=0, private, must-revalidate" with an ETag), plus a cookie
    private static let railsResponse = "HTTP/1.1 200 OK\r\n"
        + "Content-Type: application/json\r\n"
        + "Content-Length: 2\r\n"
        + "Cache-Control: max-age=0, private, must-revalidate\r\n"
        + "ETag: W/\"shopkeeper-data\"\r\n"
        + "Set-Cookie: tracker=abc; Path=/\r\n"
        + "Connection: close\r\n\r\n"
        + "{}"

    @Test
    func responsesAreNotCached() async throws {
        let server = try await TestHTTPServer.start { _ in Self.railsResponse }
        defer { server.stop() }
        let url = try #require(URL(string: "http://127.0.0.1:\(server.port)/cache-\(UUID().uuidString)"))

        _ = try await URLSession.api.data(from: url)
        _ = try await URLSession.api.data(from: url)

        // A cached response would be revalidated with If-None-Match on the second request
        #expect(server.requests.count == 2)
        #expect(server.requests.last?.headers["if-none-match"] == nil)
        #expect(URLCache.shared.cachedResponse(for: URLRequest(url: url)) == nil)
    }

    @Test
    func cookiesAreNotStoredOrSent() async throws {
        let server = try await TestHTTPServer.start { _ in Self.railsResponse }
        defer { server.stop() }
        let url = try #require(URL(string: "http://127.0.0.1:\(server.port)/cookie-\(UUID().uuidString)"))

        _ = try await URLSession.api.data(from: url)
        _ = try await URLSession.api.data(from: url)

        #expect(server.requests.count == 2)
        #expect(server.requests.last?.headers["cookie"] == nil)
    }
}
