//
//  DemoItemTagRepositoryTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

@Suite
struct DemoItemTagRepositoryTest {
    @MainActor
    struct Tests {
        let repository = DemoItemTagRepository(itemTagsService: ItemTagsService())

        @Test
        func findBy() {
            repository.reload(shopId: "1")

            let itemTags = repository.findBy(id: "1")
            #expect(itemTags.name == "A001")
        }

        @Test
        func reload() {
            repository.reload(shopId: "1")

            #expect(repository.itemTags.count == 3)
            #expect(repository.state == .hasData)
        }

        @Test
        func fetchAll() async throws {
            let itemTags = try await repository.fetchAll(shopId: "1")

            #expect(itemTags.count == 3)
        }

        @Test
        func fetchDetail() async throws {
            repository.reload(shopId: "1")

            let itemTag = try await repository.fetchDetail(id: "1")
            #expect(itemTag.name == "A001")
        }

        @Test
        func create() async throws {
            let shopId = "1"
            repository.reload(shopId: shopId)

            let newName = "A099"
            let newItemTag = ItemTag(
                shopId: shopId,
                name: newName,
                description: "",
                position: nil,
                state: .idled,
                createdAt: .now,
                completedAt: nil,
                shopName: "Mock ItemTag"
            )

            let createdItemTag = try await repository.create(shopId: shopId, itemTag: newItemTag)
            #expect(createdItemTag.name == newName)
            #expect(repository.itemTags.count == 4)
        }

        @Test
        func update() async throws {
            repository.reload(shopId: "1")

            var itemTag = repository.findBy(id: "1")
            let newName = "B001"
            itemTag.name = newName
            let updatedItemTag = try await repository.update(id: "1", itemTag: itemTag)
            #expect(updatedItemTag.name == newName)
        }

        @Test
        func destroy() async throws {
            repository.reload(shopId: "1")

            try await repository.destroy(id: "1")
            #expect(!repository.itemTags.contains { $0.id == "1" })
        }

        @Test
        func complete() async throws {
            repository.reload(shopId: "1")

            var itemTag = repository.findBy(id: "1")
            itemTag.completedAt = nil
            _ = try await repository.update(id: "1", itemTag: itemTag)

            let completedItemTag = try await repository.complete(id: "1")
            #expect(completedItemTag.state == ItemTagState.completed)
            #expect(completedItemTag.completedAt != nil)
        }

        @Test
        func idle() async throws {
            repository.reload(shopId: "1")

            var itemTag = repository.findBy(id: "1")
            itemTag.state = .completed
            itemTag.completedAt = .now
            _ = try await repository.update(id: "1", itemTag: itemTag)

            let idledItemTag = try await repository.idle(id: "1")
            #expect(idledItemTag.state == .idled)
            #expect(idledItemTag.completedAt == nil)
        }
    }
}
