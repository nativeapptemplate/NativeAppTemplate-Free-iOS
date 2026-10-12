//
//  TestHTTPServer.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Network

/// A small HTTP/1.1 server on a random local port, so tests can run the real
/// networking stack (Service, Request, adapters, repositories) without the API.
///
/// Each connection carries one request and is closed after the response.
/// Point a service at it with `server.client()`: the app's
/// ATS does not apply to IP addresses, so plain HTTP to 127.0.0.1 goes through
/// `URLSession.api` unchanged.
final class TestHTTPServer: @unchecked Sendable {
    /// A request as the server received it
    struct Request: Sendable {
        let method: String
        /// The request target: the path plus any query, e.g. "/a/b?page=2"
        let target: String
        /// Header names are lowercased
        let headers: [String: String]
        let body: Data

        var path: String {
            String(target.prefix { $0 != "?" })
        }

        var queryItems: [URLQueryItem] {
            URLComponents(string: target)?.queryItems ?? []
        }
    }

    private let listener: NWListener
    private let respond: @Sendable (Request) -> String
    private let lock = NSLock()
    private var _requests: [Request] = []

    var port: UInt16 {
        listener.port!.rawValue
    }

    /// Every request received so far, oldest first
    var requests: [Request] {
        lock.withLock { _requests }
    }

    var lastRequestHeaders: [String: String]? {
        requests.last?.headers
    }

    private init(respond: @escaping @Sendable (Request) -> String) throws {
        listener = try NWListener(using: .tcp, on: .any)
        self.respond = respond
    }

    static func start(respond: @escaping @Sendable (Request) -> String) async throws -> TestHTTPServer {
        let server = try TestHTTPServer(respond: respond)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            nonisolated(unsafe) var resumed = false
            server.listener.stateUpdateHandler = { state in
                switch state {
                case .ready where !resumed:
                    resumed = true
                    continuation.resume()
                case let .failed(error) where !resumed:
                    resumed = true
                    continuation.resume(throwing: error)
                default:
                    break
                }
            }
            server.listener.newConnectionHandler = { server.handle($0) }
            server.listener.start(queue: .global())
        }
        return server
    }

    func stop() {
        listener.cancel()
    }

    /// An API client whose requests go to this server
    func client(accountId: String = "account-id") -> NativeAppTemplateAPI {
        NativeAppTemplateAPI(
            // NativeAppTemplateEnvironment.swift is also compiled into the test target
            environment: NativeAppTemplate
                .NativeAppTemplateEnvironment(baseURL: URL(string: "http://127.0.0.1:\(port)")!),
            authToken: "token",
            client: "client",
            expiry: "expiry",
            uid: "uid",
            accountId: accountId
        )
    }

    /// A complete HTTP/1.1 response with the given status and body
    static func response(status: Int, body: String = "", contentType: String = "application/json") -> String {
        "HTTP/1.1 \(status) \(HTTPURLResponse.localizedString(forStatusCode: status))\r\n"
            + "Content-Type: \(contentType)\r\n"
            + "Content-Length: \(Data(body.utf8).count)\r\n"
            + "Cache-Control: no-store\r\n"
            + "Connection: close\r\n\r\n"
            + body
    }

    /// A response whose body is `object` as JSON
    static func json(status: Int = 200, _ object: Any) -> String {
        let data = (try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])) ?? Data()
        return response(status: status, body: String(decoding: data, as: UTF8.self))
    }

    private func handle(_ connection: NWConnection) {
        connection.start(queue: .global())
        receive(on: connection, buffer: Data())
    }

    /// Reads until the headers and a body of Content-Length bytes have arrived
    private func receive(on connection: NWConnection, buffer: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65_536) { data, _, isComplete, error in
            var buffer = buffer
            if let data {
                buffer.append(data)
            }

            if let request = Self.parse(buffer) {
                self.lock.withLock { self._requests.append(request) }
                connection.send(content: Data(self.respond(request).utf8), completion: .contentProcessed { _ in
                    connection.cancel()
                })
            } else if isComplete || error != nil {
                connection.cancel()
            } else {
                self.receive(on: connection, buffer: buffer)
            }
        }
    }

    private static func parse(_ buffer: Data) -> Request? {
        let separator = Data("\r\n\r\n".utf8)
        guard let headerEnd = buffer.range(of: separator) else { return nil }

        let head = String(decoding: buffer[..<headerEnd.lowerBound], as: UTF8.self)
        var lines = head.components(separatedBy: "\r\n")
        let requestLine = lines.removeFirst().split(separator: " ")
        guard requestLine.count >= 2 else { return nil }

        var headers: [String: String] = [:]
        for line in lines {
            guard let colon = line.firstIndex(of: ":") else { continue }
            let name = line[..<colon].lowercased()
            headers[name] = line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
        }

        let body = buffer[headerEnd.upperBound...]
        let contentLength = headers["content-length"].flatMap(Int.init) ?? 0
        guard body.count >= contentLength else { return nil }

        return Request(
            method: String(requestLine[0]),
            target: String(requestLine[1]),
            headers: headers,
            body: Data(body.prefix(contentLength))
        )
    }
}
