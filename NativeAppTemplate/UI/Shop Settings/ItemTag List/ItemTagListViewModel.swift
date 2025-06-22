//
//  ItemTagListViewModel.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class ItemTagListViewModel {
  var isShowingCreateSheet = false
  var isDeleting = false
  var isShowingDeleteConfirmationDialog = false
  var state: DataState { itemTagRepository.state }
  var itemTags: [ItemTag] { itemTagRepository.itemTags }
  private let itemTagRepository: ItemTagRepositoryProtocol
  private let messageBus: MessageBus
  private let sessionController: SessionControllerProtocol
  let shop: Shop
  
  init(
    itemTagRepository: ItemTagRepositoryProtocol,
    messageBus: MessageBus,
    sessionController: SessionControllerProtocol,
    shop: Shop
  ) {
    self.itemTagRepository = itemTagRepository
    self.messageBus = messageBus
    self.sessionController = sessionController
    self.shop = shop
  }
  
  var isBusy: Bool {
    isDeleting
  }
  
  var isEmpty: Bool {
    itemTags.isEmpty
  }
  
  func reload() {
    itemTagRepository.reload(shopId: shop.id)
  }

  func destroyItemTag(itemTagId: String) {
    Task {
      isDeleting = true
      
      do {
        try await itemTagRepository.destroy(id: itemTagId)
        messageBus.post(message: Message(level: .success, message: .itemTagDeleted))
        reload()
      } catch {
        messageBus.post(message: Message(level: .error, message: "\(String.itemTagDeletedError) \(error.localizedDescription)", autoDismiss: false))
      }
      
      isDeleting = false
    }
  }
  
  func createItemTagDetailViewModel(itemTagId: String) -> ItemTagDetailViewModel {
    ItemTagDetailViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      nfcManager: appSingletons.nfcManager,
      shop: shop,
      itemTagId: itemTagId
    )
  }
  
  func createItemTagCreateViewModel() -> ItemTagCreateViewModel {
    ItemTagCreateViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      shopId: shop.id
    )
  }
}
