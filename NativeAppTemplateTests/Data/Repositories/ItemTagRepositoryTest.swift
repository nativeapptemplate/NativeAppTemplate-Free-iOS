//
//  ItemTagRepositoryTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
struct ItemTagRepositoryTest {
    /// Nothing listens on port 1, so requests fail at once without the network
    private func makeRepository() -> ItemTagRepository {
        let client = NativeAppTemplateAPI(
            // NativeAppTemplateEnvironment.swift is also compiled into the test target
            environment: NativeAppTemplate.NativeAppTemplateEnvironment(baseURL: URL(string: "http://127.0.0.1:1")!),
            authToken: "",
            client: "",
            expiry: "",
            uid: "",
            accountId: ""
        )
        return ItemTagRepository(itemTagsService: ItemTagsService(networkClient: client))
    }

    /// The repository is shared by every shop's item tag list, and the list
    /// keeps showing `itemTags` while it loads. Opening shop B after shop A
    /// must not show A's tags (tapping one would open A's tag) while B loads.
    @Test
    func reloadPageForAnotherShopDropsThePreviousShopsTags() {
        let repository = makeRepository()
        repository.itemTags = [
            ItemTag(id: "a1", shopId: "A", name: "A1"),
            ItemTag(id: "a2", shopId: "A", name: "A2")
        ]
        repository.paginationMeta = PaginationMeta(currentPage: 1, totalPages: 3, totalCount: 60, limit: 20)
        repository.state = .hasData

        repository.reloadPage(shopId: "B", page: 1)

        #expect(repository.state == .loading)
        #expect(!repository.itemTags.contains { $0.shopId == "A" })
        // A's page count must not let the list page B with A's page numbers
        #expect(repository.paginationMeta == nil)
    }

    /// Refreshing the same shop keeps its list on screen while it loads
    /// (ItemTagListView shows the list, not a spinner, during .loading)
    @Test
    func reloadPageForTheSameShopKeepsItsTags() {
        let repository = makeRepository()
        repository.itemTags = [ItemTag(id: "a1", shopId: "A", name: "A1")]
        repository.state = .hasData

        repository.reloadPage(shopId: "A", page: 1)

        #expect(repository.state == .loading)
        #expect(repository.itemTags.map(\.id) == ["a1"])
    }

    /// complete and idle act on one item tag (shop detail, item tag detail).
    /// Their failure must not turn the loaded item tag list into
    /// ItemTagListView's error screen, which shows for .failed.
    @Test
    func failedCompleteKeepsTheListState() async {
        let repository = makeRepository()
        repository.itemTags = [ItemTag(id: "a1", shopId: "A", name: "A1")]
        repository.state = .hasData

        await #expect(throws: (any Error).self) {
            try await repository.complete(id: "a1")
        }

        #expect(repository.state == .hasData)
    }

    @Test
    func failedIdleKeepsTheListState() async {
        let repository = makeRepository()
        repository.itemTags = [ItemTag(id: "a1", shopId: "A", name: "A1")]
        repository.state = .hasData

        await #expect(throws: (any Error).self) {
            try await repository.idle(id: "a1")
        }

        #expect(repository.state == .hasData)
    }

    /// An item tag resource as the API's ItemTagSerializer writes it (ItemTagAdapter's attributes)
    private nonisolated static func itemTagResource(id: String, shopId: String = "A") -> [String: Any] {
        [
            "id": id,
            "type": "item_tag",
            "attributes": [
                "shop_id": shopId,
                "name": id,
                "description": "",
                "position": 1,
                "state": "idled",
                "created_at": "2026-01-01T00:00:00.000Z",
                "shop_name": "Shop A"
            ] as [String: Any]
        ]
    }

    /// If the list shifts between page loads (a tag is added or removed), page 2 can
    /// repeat the last tag of page 1. Appending it again would list it twice, and
    /// ForEach is keyed by id. Pages [t1, t2] then [t2, t3] must give [t1, t2, t3]:
    /// the first occurrence is kept, in order (as the Android app does).
    @Test
    func loadNextPageSkipsTagsAlreadyListed() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json([
                "data": [Self.itemTagResource(id: "t2"), Self.itemTagResource(id: "t3")],
                "meta": ["current_page": 2, "total_pages": 2, "total_count": 4, "limit": 2]
            ])
        }
        defer { server.stop() }

        let repository = ItemTagRepository(itemTagsService: ItemTagsService(networkClient: server.client()))
        repository.itemTags = [ItemTag(id: "t1", shopId: "A", name: "t1"), ItemTag(id: "t2", shopId: "A", name: "t2")]
        repository.paginationMeta = PaginationMeta(currentPage: 1, totalPages: 2, totalCount: 4, limit: 2)
        repository.state = .hasData

        repository.loadNextPage(shopId: "A")
        await waitUntil { repository.paginationMeta?.currentPage == 2 && !repository.isLoadingMore }

        #expect(repository.itemTags.map(\.id) == ["t1", "t2", "t3"])
        // The page request itself asked for page 2
        #expect(server.requests.last?.queryItems.first { $0.name == "page" }?.value == "2")
    }
}

