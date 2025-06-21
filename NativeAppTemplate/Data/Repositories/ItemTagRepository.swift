//
//  ItemTagRepository.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/01.
//

import SwiftUI

@MainActor @Observable class ItemTagRepository {
  let itemTagsService: ItemTagsService
  
  var itemTags: [ItemTag] = []
  var state: DataState = .initial
  
  init(itemTagsService: ItemTagsService) {
    self.itemTagsService = itemTagsService
  }
  
  var isEmpty: Bool { itemTags.isEmpty }
  
  func findBy(id: String) -> ItemTag {
    let itemTag = itemTags.first { $0.id == id }
    return itemTag!
  }
  
  func reload(shopId: String) {
    if Task.isCancelled {
      return
    }

    if state == .loading {
      return
    }
    
    state = .loading
    
    Task { @MainActor in
      do {
        itemTags = try await itemTagsService.allItemTags(shopId: shopId)
        state = .hasData
      } catch {
        state = .failed
        Failure
          .fetch(from: Self.self, reason: error.localizedDescription)
          .log()
      }
    }
  }
  
  func fetchAll(shopId: String) async throws -> [ItemTag] {
    do {
      itemTags = try await itemTagsService.allItemTags(shopId: shopId)
      return itemTags
    } catch {
      Failure
        .fetch(from: Self.self, reason: error.localizedDescription)
        .log()
      throw error
    }
  }
  
  func fetchDetail(id: String) async throws -> ItemTag {
    do {
      let itemTag = try await itemTagsService.itemTagDetail(id: id)
      let itemTagIndex = (itemTags.firstIndex { $0.id == itemTag.id })
      if itemTagIndex == nil {
        itemTags.append(itemTag)
      } else {
        itemTags[itemTagIndex!] = itemTag
      }

      return itemTag
    } catch {
      Failure
        .fetch(from: Self.self, reason: error.localizedDescription)
        .log()
      throw error
    }
  }
  
  func create(shopId: String, itemTag: ItemTag) async throws -> ItemTag {
    do {
      let createdItemTag = try await itemTagsService.makeItemTag(shopId: shopId, itemTag: itemTag)
      return createdItemTag
    } catch {
      Failure
        .create(from: Self.self, reason: error.localizedDescription)
        .log()
      throw error
    }
  }
  
  func update(id: String, itemTag: ItemTag) async throws -> ItemTag {
    do {
      let updatedItemTag = try await itemTagsService.updateItemTag(id: id, itemTag: itemTag)
      let itemTagIndex = (itemTags.firstIndex { $0.id == updatedItemTag.id })
      if itemTagIndex != nil {
        itemTags[itemTagIndex!] = updatedItemTag
      }
      
      return updatedItemTag
    } catch {
      Failure
        .update(from: Self.self, reason: error.localizedDescription)
        .log()
      throw error
    }
  }
  
  func destroy(id: String) async throws {
    do {
      try await itemTagsService.destroyItemTag(id: id)
    } catch {
      Failure
        .destroy(from: Self.self, reason: error.localizedDescription)
        .log()
      throw error
    }
  }
  
  func complete(id: String) async throws -> ItemTag {
    do {
      let completedItemTag = try await itemTagsService.completeItemTag(id: id)
      let itemTagIndex = (itemTags.firstIndex { $0.id == completedItemTag.id })
      if itemTagIndex != nil {
        itemTags[itemTagIndex!] = completedItemTag
      }
      
      return completedItemTag
    } catch {
      self.state = .failed
      Failure
        .update(from: Self.self, reason: error.localizedDescription)
        .log()
      throw error
    }
  }
  
  func reset(id: String) async throws -> ItemTag {
    do {
      let resetItemTag = try await itemTagsService.resetItemTag(id: id)
      let itemTagIndex = (itemTags.firstIndex { $0.id == resetItemTag.id })
      if itemTagIndex != nil {
        itemTags[itemTagIndex!] = resetItemTag
      }
      
      return resetItemTag
    } catch {
      self.state = .failed
      Failure
        .update(from: Self.self, reason: error.localizedDescription)
        .log()
      throw error
    }
  }
}
