//
//  ItemTagRepositoryPaginationTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// The real ItemTagRepository paging through a local server
@MainActor
struct ItemTagRepositoryPaginationTest {
    /// Serves page 1 (t1, t2) and page 2 (t3) of a 2-page list; a request
    /// without a page is the API's first page
    private nonisolated static func twoPages(_ request: TestHTTPServer.Request) -> String {
        let page = request.queryItems.first { $0.name == "page" }?.value ?? "1"
        return page == "2"
            ? TestHTTPServer.json(JSONAPIFixtures.itemTagPage(ids: ["t3"], currentPage: 2, totalPages: 2))
            : TestHTTPServer.json(JSONAPIFixtures.itemTagPage(ids: ["t1", "t2"], currentPage: 1, totalPages: 2))
    }

    private func makeRepository(_ server: TestHTTPServer) -> ItemTagRepository {
        ItemTagRepository(itemTagsService: ItemTagsService(networkClient: server.client()))
    }

    @Test
    func reloadPageLoadsTheFirstPage() async throws {
        let server = try await TestHTTPServer.start(respond: { Self.twoPages($0) })
        defer { server.stop() }
        let repository = makeRepository(server)

        repository.reloadPage(shopId: "shop-1", page: 1)
        await waitUntil { repository.state != .loading }

        #expect(repository.state == .hasData)
        #expect(repository.itemTags.map(\.id) == ["t1", "t2"])
        #expect(repository.paginationMeta?.currentPage == 1)
        #expect(repository.paginationMeta?.hasMorePages == true)
        #expect(server.requests.map(\.queryItems) == [[URLQueryItem(name: "page", value: "1")]])
    }

    /// loadNextPage asks for currentPage + 1 and appends it
    @Test
    func loadNextPageAppendsTheNextPage() async throws {
        let server = try await TestHTTPServer.start(respond: { Self.twoPages($0) })
        defer { server.stop() }
        let repository = makeRepository(server)
        repository.reloadPage(shopId: "shop-1", page: 1)
        await waitUntil { repository.state == .hasData }

        repository.loadNextPage(shopId: "shop-1")
        #expect(repository.isLoadingMore)
        await waitUntil { !repository.isLoadingMore }

        #expect(repository.itemTags.map(\.id) == ["t1", "t2", "t3"])
        #expect(repository.paginationMeta?.currentPage == 2)
        #expect(repository.paginationMeta?.hasMorePages == false)
        #expect(server.requests.last?.queryItems == [URLQueryItem(name: "page", value: "2")])
    }

    /// On the last page (currentPage == totalPages) there is nothing to ask for
    @Test
    func loadNextPageOnTheLastPageSendsNothing() async throws {
        let server = try await TestHTTPServer.start(respond: { Self.twoPages($0) })
        defer { server.stop() }
        let repository = makeRepository(server)
        repository.reloadPage(shopId: "shop-1", page: 2)
        await waitUntil { repository.state == .hasData }

        repository.loadNextPage(shopId: "shop-1")

        #expect(!repository.isLoadingMore)
        #expect(server.requests.count == 1)
    }

    /// A second loadNextPage while one is running must not ask for the page twice
    @Test
    func loadNextPageWhileLoadingSendsOneRequest() async throws {
        let server = try await TestHTTPServer.start(respond: { Self.twoPages($0) })
        defer { server.stop() }
        let repository = makeRepository(server)
        repository.reloadPage(shopId: "shop-1", page: 1)
        await waitUntil { repository.state == .hasData }

        repository.loadNextPage(shopId: "shop-1")
        repository.loadNextPage(shopId: "shop-1")
        await waitUntil { !repository.isLoadingMore }

        // One page-1 request, then exactly one page-2 request
        #expect(server.requests.count == 2)
        #expect(repository.itemTags.map(\.id) == ["t1", "t2", "t3"])
    }

    /// A failed next page keeps what is on screen and lets the user scroll again
    @Test
    func failedNextPageKeepsTheLoadedTags() async throws {
        let server = try await TestHTTPServer.start { request in
            request.queryItems.contains { $0.value == "2" }
                ? TestHTTPServer.json(status: 500, ["error_message": "Internal server error"])
                : Self.twoPages(request)
        }
        defer { server.stop() }
        let repository = makeRepository(server)
        repository.reloadPage(shopId: "shop-1", page: 1)
        await waitUntil { repository.state == .hasData }

        repository.loadNextPage(shopId: "shop-1")
        await waitUntil { server.requests.count == 2 && !repository.isLoadingMore }

        #expect(repository.itemTags.map(\.id) == ["t1", "t2"])
        #expect(repository.state == .hasData)
        #expect(repository.paginationMeta?.currentPage == 1)
    }

    @Test
    func failedReloadPageIsFailed() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json(status: 500, ["error_message": "Internal server error"])
        }
        defer { server.stop() }
        let repository = makeRepository(server)

        repository.reloadPage(shopId: "shop-1", page: 1)
        await waitUntil { repository.state != .loading }

        #expect(repository.state == .failed)
        #expect(repository.itemTags.isEmpty)
    }
}
