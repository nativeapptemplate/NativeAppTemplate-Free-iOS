//
//  DemoItemTagRepository.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
final class DemoItemTagRepository: ItemTagRepositoryProtocol {
    var itemTags: [ItemTag] = []
    var state: DataState = .initial
    var isEmpty: Bool {
        itemTags.isEmpty
    }

    var paginationMeta: PaginationMeta?
    var isLoadingMore = false

    required init(itemTagsService: ItemTagsService) {}

    func findBy(id: String) -> ItemTag {
        itemTags.first { $0.id == id }!
    }

    func reload(shopId: String) {
        state = .loading

        let allItemTags = fetchAll()
        itemTags = allItemTags.filter { $0.shopId == shopId }

        state = .hasData
    }

    func reloadPage(shopId: String, page: Int) {
        reload(shopId: shopId)
    }

    func loadNextPage(shopId: String) {
        // No-op for demo
    }

    func fetchAll(shopId: String) async throws -> [ItemTag] {
        let allItemTags = fetchAll()
        return allItemTags.filter { $0.shopId == shopId }
    }

    func fetchDetail(id: String) async throws -> ItemTag {
        itemTags.first { $0.id == id }!
    }

    func create(shopId: String, itemTag: ItemTag) async throws -> ItemTag {
        itemTags.append(itemTag)
        return itemTag
    }

    func update(id: String, itemTag: ItemTag) async throws -> ItemTag {
        let index = itemTags.firstIndex { $0.id == id }!
        itemTags[index] = itemTag

        return itemTag
    }

    func destroy(id: String) async throws {
        itemTags.removeAll { $0.id == id }
    }

    func complete(id: String) async throws -> ItemTag {
        var itemTag = itemTags.first { $0.id == id }!
        itemTag.state = .completed
        itemTag.completedAt = .now

        let index = itemTags.firstIndex { $0.id == id }!
        itemTags[index] = itemTag

        return itemTag
    }

    func reset(id: String) async throws -> ItemTag {
        var itemTag = itemTags.first { $0.id == id }!
        itemTag.state = .idled
        itemTag.completedAt = nil

        let index = itemTags.firstIndex { $0.id == id }!
        itemTags[index] = itemTag

        return itemTag
    }

    private func fetchAll() -> [ItemTag] {
        [
            mockItemTag(id: "1", shopId: "1", name: "A001"),
            mockItemTag(id: "2", shopId: "1", name: "A002"),
            mockItemTag(id: "3", shopId: "1", name: "A003"),
            mockItemTag(id: "4", shopId: "2", name: "A001"),
            mockItemTag(id: "5", shopId: "2", name: "A002"),
            mockItemTag(id: "6", shopId: "2", name: "A003"),
            mockItemTag(id: "7", shopId: "2", name: "A004")
        ]
    }

    // MARK: - Helpers

    private func mockItemTag(
        id: String = UUID().uuidString,
        shopId: String = UUID().uuidString,
        name: String = "Mock ItemTag"
    ) -> ItemTag {
        ItemTag(
            id: id,
            shopId: shopId,
            name: name,
            description: "",
            position: nil,
            state: .idled,
            createdAt: .now,
            completedAt: nil,
            shopName: "Mock ItemTag"
        )
    }
}
