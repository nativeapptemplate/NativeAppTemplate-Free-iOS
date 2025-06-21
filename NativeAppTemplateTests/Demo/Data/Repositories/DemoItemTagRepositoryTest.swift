//
//  DemoItemTagRepositoryTest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/05/17.
//

import Testing
@testable import NativeAppTemplate

@Suite
struct DemoItemTagRepositoryTest {
  @MainActor
  struct Tests {
    let repository = DemoItemTagRepository(itemTagsService: ItemTagsService())

    @Test
    func findBy() {
      repository.reload(shopId: "1")

      let itemTags = repository.findBy(id: "1")
      #expect(itemTags.queueNumber == "A001")
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
      #expect(itemTag.queueNumber == "A001")
    }

    @Test
    func create() async throws {
      let shopId = "1"
      repository.reload(shopId: shopId)

      let newQueueNumber = "A099"
      let newItemTag = ItemTag(
        shopId: shopId,
        queueNumber: newQueueNumber,
        state: .idled,
        scanState: .unscanned,
        createdAt: .now,
        customerReadAt: nil,
        completedAt: nil,
        shopName: "Mock ItemTag",
        alreadyCompleted: false
      )

      let createdItemTag = try await repository.create(shopId: shopId, itemTag: newItemTag)
      #expect(createdItemTag.queueNumber == newQueueNumber)
      #expect(repository.itemTags.count == 4)
    }

    @Test
    func update() async throws {
      repository.reload(shopId: "1")

      var itemTag = repository.findBy(id: "1")
      let newQueueNumber = "B001"
      itemTag.queueNumber = newQueueNumber
      let updatedItemTag = try await repository.update(id: "1", itemTag: itemTag)
      #expect(updatedItemTag.queueNumber == newQueueNumber)
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
    func reset() async throws {
      repository.reload(shopId: "1")

      var itemTag = repository.findBy(id: "1")
      itemTag.state = .completed
      itemTag.scanState = .scanned
      itemTag.completedAt = .now
      itemTag.customerReadAt = .now
      _ = try await repository.update(id: "1", itemTag: itemTag)

      let resetItemTag = try await repository.reset(id: "1")
      #expect(resetItemTag.state == .idled)
      #expect(resetItemTag.scanState == .unscanned)
      #expect(resetItemTag.completedAt == nil)
      #expect(resetItemTag.customerReadAt == nil)
    }
  }
}
