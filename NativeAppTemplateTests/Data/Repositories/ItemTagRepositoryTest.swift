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
}
