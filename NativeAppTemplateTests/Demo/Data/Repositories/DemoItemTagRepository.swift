//
//  DemoItemTagRepository.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/05/17.
//

import Testing
@testable import NativeAppTemplate
import Foundation

@MainActor
final class DemoItemTagRepository: ItemTagRepositoryProtocol {
  var itemTags: [ItemTag] = []
  var state: DataState = .initial
  var isEmpty: Bool { itemTags.isEmpty }

  required init(itemTagsService: ItemTagsService) {
  }

  func findBy(id: String) -> ItemTag {
    itemTags.first { $0.id == id }!
  }

  func reload(shopId: String) {
    state = .loading

    let allItemTags = fetchAll()
    itemTags = allItemTags.filter { $0.shopId == shopId }

    state = .hasData
  }

  func fetchAll(shopId: String) async throws -> [ItemTag] {
    let allItemTags = fetchAll()
    let itemTags = allItemTags.filter { $0.shopId == shopId }

    return itemTags
  }

  func fetchDetail(id: String) async throws -> ItemTag {
    return itemTags.first { $0.id == id }!
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
    itemTag.scanState = .unscanned
    itemTag.completedAt = nil
    itemTag.customerReadAt = nil

    let index = itemTags.firstIndex { $0.id == id }!
    itemTags[index] = itemTag

    return itemTag
  }

  private func fetchAll() -> [ItemTag] {
    return [
      mockItemTag(id: "1", shopId: "1", queueNumber: "A001"),
      mockItemTag(id: "2", shopId: "1", queueNumber: "A002"),
      mockItemTag(id: "3", shopId: "1", queueNumber: "A003"),
      mockItemTag(id: "4", shopId: "2", queueNumber: "A001"),
      mockItemTag(id: "5", shopId: "2", queueNumber: "A002"),
      mockItemTag(id: "6", shopId: "2", queueNumber: "A003"),
      mockItemTag(id: "7", shopId: "2", queueNumber: "A004")
     ]
 }

  // MARK: - Helpers
  private func mockItemTag(
    id: String = UUID().uuidString,
    shopId: String = UUID().uuidString,
    queueNumber: String = "Mock ItemTag"
  ) -> ItemTag {
    ItemTag(
      id: id,
      shopId: shopId,
      queueNumber: queueNumber,
      state: .idled,
      scanState: .unscanned,
      createdAt: .now,
      customerReadAt: nil,
      completedAt: nil,
      shopName: "Mock ItemTag",
      alreadyCompleted: false
    )
  }
}
