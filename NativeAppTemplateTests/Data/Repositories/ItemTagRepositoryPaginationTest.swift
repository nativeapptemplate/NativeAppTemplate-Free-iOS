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

    // MARK: - Switching shops while a page is loading

    /// Holds shop-A's requests until `releaseA` is signalled; shop-B's are answered
    /// at once. Each shop's page lists its own tags (a1, a2 then a3 / b1).
    private nonisolated static func shopServer(releaseA: DispatchSemaphore) async throws -> TestHTTPServer {
        try await TestHTTPServer.start { request in
            if request.path.contains("/shops/shop-A/") {
                releaseA.wait()
                let page = request.queryItems.first { $0.name == "page" }?.value ?? "1"
                return TestHTTPServer.json(JSONAPIFixtures.itemTagPage(
                    ids: page == "1" ? ["a1", "a2"] : ["a3"],
                    currentPage: Int(page) ?? 1,
                    totalPages: 2,
                    shopId: "shop-A"
                ))
            }
            return TestHTTPServer.json(JSONAPIFixtures.itemTagPage(
                ids: ["b1"],
                currentPage: 1,
                totalPages: 1,
                shopId: "shop-B"
            ))
        }
    }

    /// Opening shop B while shop A's first page is still loading: B's list must
    /// load B's tags, and A's late page must not replace them
    @Test
    func reloadingAnotherShopWhileOneIsLoadingShowsThatShop() async throws {
        let releaseA = DispatchSemaphore(value: 0)
        let server = try await Self.shopServer(releaseA: releaseA)
        defer { server.stop() }
        let repository = makeRepository(server)

        repository.reloadPage(shopId: "shop-A", page: 1)
        await waitUntil { server.requests.count == 1 }
        repository.reloadPage(shopId: "shop-B", page: 1)
        await waitUntil(timeout: .seconds(10)) { repository.state == .hasData }

        #expect(repository.itemTags.map(\.id) == ["b1"])

        // A's answer arrives late. Nothing on screen shows it was handled, so give it time
        releaseA.signal()
        try await Task.sleep(for: .milliseconds(500))

        #expect(repository.itemTags.map(\.id) == ["b1"])
        #expect(repository.itemTags.allSatisfy { $0.shopId == "shop-B" })
        #expect(repository.state == .hasData)
    }

    /// Shop A's detail screen fetches all of A's tags (fetchAll). When that answer
    /// arrives after the user went on to shop B's item tag list, B's list must keep
    /// B's tags; seen on the iPhone against the local API before the fix
    @Test
    func previousShopsDetailFetchDoesNotReplaceAnotherShopsList() async throws {
        let releaseA = DispatchSemaphore(value: 0)
        let server = try await Self.shopServer(releaseA: releaseA)
        defer { server.stop() }
        let repository = makeRepository(server)

        let detailFetch = Task { try await repository.fetchAll(shopId: "shop-A") }
        await waitUntil { server.requests.count == 1 }
        repository.reloadPage(shopId: "shop-B", page: 1)
        await waitUntil(timeout: .seconds(10)) { repository.state == .hasData }
        releaseA.signal()
        let shopATags = try await detailFetch.value

        // The detail gets A's page 1 (a1, a2: shopServer's answer without a page)
        #expect(shopATags.map(\.id) == ["a1", "a2"])
        // B's list is unchanged: b1 with B's meta
        #expect(repository.itemTags.map(\.id) == ["b1"])
        #expect(repository.paginationMeta?.totalPages == 1)
        #expect(repository.state == .hasData)
    }

    /// Shop A's next page arriving after the user opened shop B must not be
    /// appended to B's list
    @Test
    func nextPageOfThePreviousShopIsNotAppendedToAnotherShop() async throws {
        // Starts at 0 and ends at 0: libdispatch crashes when a semaphore is freed
        // below its starting value
        let releaseA = DispatchSemaphore(value: 0)
        let server = try await Self.shopServer(releaseA: releaseA)
        defer { server.stop() }
        let repository = makeRepository(server)
        // Let page 1 through; page 2 waits
        releaseA.signal()
        repository.reloadPage(shopId: "shop-A", page: 1)
        await waitUntil { repository.state == .hasData }
        repository.loadNextPage(shopId: "shop-A")
        await waitUntil { server.requests.count == 2 }

        repository.reloadPage(shopId: "shop-B", page: 1)
        await waitUntil { repository.state == .hasData && repository.itemTags.contains { $0.id == "b1" } }
        releaseA.signal()
        // Nothing on screen shows A's late page was handled, so give it time
        try await Task.sleep(for: .milliseconds(500))

        #expect(repository.itemTags.map(\.id) == ["b1"])
        // B's own meta (1 of 1), not A's page 2
        #expect(repository.paginationMeta?.currentPage == 1)
        #expect(repository.paginationMeta?.totalPages == 1)
        // B's list can load its own next pages
        #expect(!repository.isLoadingMore)
    }
}
