//
//  TestItemTagRepository.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import Foundation
@testable import NativeAppTemplate

@MainActor
final class TestItemTagRepository: ItemTagRepositoryProtocol {
  var itemTags: [ItemTag] = []
  var state: DataState = .initial
  var isEmpty: Bool { itemTags.isEmpty }

  // A test-only
  var error: NativeAppTemplateAPIError?

  required init(itemTagsService: ItemTagsService) {
  }

  func findBy(id: String) -> ItemTag {
    guard let itemTag = itemTags.first(where: { $0.id == id }) else {
      fatalError("Test setup error: ItemTag with id '\(id)' not found. Available IDs: \(itemTags.map { $0.id })")
    }
    return itemTag
  }

  func reload(shopId: String) {
    guard error == nil else {
      state = .failed
      return
    }

    state = .loading
    state = .hasData
  }

  func fetchAll(shopId: String) async throws -> [ItemTag] {
    guard error == nil else {
      state = .failed
      throw error!
    }

    return itemTags
  }

  func fetchDetail(id: String) async throws -> ItemTag {
    guard error == nil else {
      state = .failed
      throw error!
    }

    guard let itemTag = itemTags.first(where: { $0.id == id }) else {
      throw NativeAppTemplateAPIError.requestFailed(nil, 404, "ItemTag with id '\(id)' not found")
    }
    return itemTag
  }

  func create(shopId: String, itemTag: ItemTag) async throws -> ItemTag {
    guard error == nil else {
      state = .failed
      throw error!
    }

    itemTags.append(itemTag)
    return itemTag
  }

  func update(id: String, itemTag: ItemTag) async throws -> ItemTag {
    guard error == nil else {
      state = .failed
      throw error!
    }

    if let index = itemTags.firstIndex(where: { $0.id == id }) {
      itemTags[index] = itemTag
    }

    return itemTag
  }

  func destroy(id: String) async throws {
    guard error == nil else {
      state = .failed
      throw error!
    }

    itemTags.removeAll { $0.id == id }
  }

  func complete(id: String) async throws -> ItemTag {
    guard error == nil else {
      state = .failed
      throw error!
    }

    var itemTag = findBy(id: id)
    let wasAlreadyCompleted = itemTag.alreadyCompleted
    itemTag.state = .completed
    itemTag.completedAt = Date()
    _ = try await update(id: id, itemTag: itemTag)

    // Preserve the alreadyCompleted flag for testing
    itemTag.alreadyCompleted = wasAlreadyCompleted

    return itemTag
  }

  func reset(id: String) async throws -> ItemTag {
    guard error == nil else {
      state = .failed
      throw error!
    }

    var itemTag = findBy(id: id)
    itemTag.state = .idled
    itemTag.scanState = .unscanned
    itemTag.completedAt = nil
    _ = try await update(id: id, itemTag: itemTag)

    return itemTag
  }

  // A test-only
  func setItemTags(itemTags: [ItemTag]) {
    self.itemTags = itemTags
  }
}
