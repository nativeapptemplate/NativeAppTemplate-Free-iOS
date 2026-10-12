//
//  ServiceTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// `Service.makeRequest` end to end against a local server: the URL and headers
/// it sends, JSON:API parsing, and how a non-2xx response becomes a
/// `NativeAppTemplateAPIError`. ItemTagsService stands in for every Service; they all
/// share the protocol extension.
@MainActor
@Suite(.serialized)
struct ServiceTest {
    /// Service.makeRequest: baseURL + accountId + "/api/v1" + the request's path,
    /// with the request's query items and the devise_token_auth headers
    @Test
    func requestGoesToTheAccountScopedApiPathWithSessionHeaders() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json(JSONAPIFixtures.itemTagPage(ids: [], currentPage: 2, totalPages: 2))
        }
        defer { server.stop() }

        _ = try await ItemTagsService(networkClient: server.client(accountId: "acc-1"))
            .allItemTags(shopId: "shop-9", page: 2)

        let request = try #require(server.requests.first)
        #expect(server.requests.count == 1)
        #expect(request.method == "GET")
        // GetItemTagsRequest.path is /shopkeeper/shops/{shopId}/item_tags
        #expect(request.path == "/acc-1/api/v1/shopkeeper/shops/shop-9/item_tags")
        #expect(request.queryItems == [URLQueryItem(name: "page", value: "2")])
        // The values TestHTTPServer.client sets
        #expect(request.headers["access-token"] == "token")
        #expect(request.headers["token-type"] == "Bearer")
        #expect(request.headers["client"] == "client")
        #expect(request.headers["expiry"] == "expiry")
        #expect(request.headers["uid"] == "uid")
        #expect(request.headers["source"] == "ios")
    }

    /// GetItemTagsRequest without a page sends no query (the API's first page)
    @Test
    func requestWithoutAPageHasNoQuery() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json(JSONAPIFixtures.itemTagPage(ids: [], currentPage: 1, totalPages: 1))
        }
        defer { server.stop() }

        _ = try await ItemTagsService(networkClient: server.client()).allItemTags(shopId: "shop-1")

        let request = try #require(server.requests.first)
        #expect(request.target == request.path)
    }

    @Test
    func jsonApiDataAndMetaAreParsed() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json(JSONAPIFixtures.itemTagPage(
                ids: ["t1", "t2"],
                currentPage: 1,
                totalPages: 3,
                totalCount: 5,
                limit: 2
            ))
        }
        defer { server.stop() }

        let response = try await ItemTagsService(networkClient: server.client()).allItemTags(shopId: "shop-1")

        // The ids and meta the fixture above was given
        #expect(response.itemTags.map(\.id) == ["t1", "t2"])
        #expect(response.itemTags.first?.name == "A001")
        #expect(response.itemTags.first?.state == .idled)
        let meta = try #require(response.paginationMeta)
        #expect(meta.currentPage == 1)
        #expect(meta.totalPages == 3)
        #expect(meta.totalCount == 5)
        #expect(meta.limit == 2)
    }

    /// The API puts a localized reason in error_message; Service keeps it and the status
    @Test
    func errorStatusWithErrorMessageBecomesRequestFailedWithThatMessage() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json(status: 422, ["error_message": "Name has already been taken"])
        }
        defer { server.stop() }

        let error = try await requestFailed {
            _ = try await ItemTagsService(networkClient: server.client()).itemTagDetail(id: "t1")
        }

        guard case let .requestFailed(_, statusCode, message) = error else {
            Issue.record("Expected requestFailed, got \(error)")
            return
        }
        #expect(statusCode == 422)
        #expect(message == "Name has already been taken")
        // NativeAppTemplateAPIError.errorDescription: "\(message) [Status: \(statusCode)]", prefixed with the code
        #expect(error.codedDescription == "[NATIVEAPPTEMPLATE-2001] Name has already been taken [Status: 422]")
    }

    @Test
    func errorStatusWithoutErrorMessageBecomesRequestFailedWithoutAMessage() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json(status: 500, ["errors": ["boom"]])
        }
        defer { server.stop() }

        let error = try await requestFailed {
            _ = try await ItemTagsService(networkClient: server.client()).itemTagDetail(id: "t1")
        }

        guard case let .requestFailed(_, statusCode, message) = error else {
            Issue.record("Expected requestFailed, got \(error)")
            return
        }
        #expect(statusCode == 500)
        #expect(message == nil)
    }

    /// GetItemTagDetailRequest expects exactly one resource
    @Test
    func detailWithTwoResourcesIsAProcessingError() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json(["data": [JSONAPIFixtures.itemTag(id: "t1"), JSONAPIFixtures.itemTag(id: "t2")]])
        }
        defer { server.stop() }

        let error = try await requestFailed {
            _ = try await ItemTagsService(networkClient: server.client()).itemTagDetail(id: "t1")
        }

        // GetItemTagDetailRequest.handle throws processingError(nil), NATIVEAPPTEMPLATE-2002
        #expect(error.errorCode == "NATIVEAPPTEMPLATE-2002")
    }

    /// CompleteItemTagRequest is a PATCH to /shopkeeper/item_tags/{id}/complete
    /// and reads a single resource (`data` as an object, not an array)
    @Test
    func completeIsAPatchAndParsesASingleResource() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json(["data": JSONAPIFixtures.itemTag(id: "t1", state: "completed")])
        }
        defer { server.stop() }

        let itemTag = try await ItemTagsService(networkClient: server.client(accountId: "acc-1"))
            .completeItemTag(id: "t1")

        let request = try #require(server.requests.first)
        #expect(request.method == "PATCH")
        #expect(request.path == "/acc-1/api/v1/shopkeeper/item_tags/t1/complete")
        #expect(itemTag.state == .completed)
    }

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
