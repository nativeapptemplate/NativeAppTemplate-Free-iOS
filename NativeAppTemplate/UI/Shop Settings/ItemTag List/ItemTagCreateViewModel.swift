//
//  ItemTagCreateViewModel.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class ItemTagCreateViewModel {
  var queueNumber = ""
  var isCreating = false
  var shouldDismiss = false
  
  private let itemTagRepository: ItemTagRepositoryProtocol
  private let messageBus: MessageBus
  private let sessionController: SessionControllerProtocol
  private let shopId: String
  
  init(
    itemTagRepository: ItemTagRepositoryProtocol,
    messageBus: MessageBus,
    sessionController: SessionControllerProtocol,
    shopId: String
  ) {
    self.itemTagRepository = itemTagRepository
    self.messageBus = messageBus
    self.sessionController = sessionController
    self.shopId = shopId
  }
  
  var isBusy: Bool {
    isCreating
  }
  
  var hasInvalidData: Bool {
    hasInvalidDataQueueNumber
  }
  
  var hasInvalidDataQueueNumber: Bool {
    if Utility.isBlank(queueNumber) {
      return true
    }
    
    if !queueNumber.isAlphanumeric(ignoreDiacritics: true) {
      return true
    }
    
    if !(2 <= queueNumber.count && queueNumber.count <= maximumQueueNumberLength) {
      return true
    }
    
    return false
  }
  
  var maximumQueueNumberLength: Int {
    sessionController.maximumQueueNumberLength
  }
  
  func validateQueueNumberLength() {
    queueNumber = String(queueNumber.prefix(maximumQueueNumberLength))
  }
  
  func createItemTag() {
    Task {
      isCreating = true
      
      do {
        let itemTag = ItemTag(queueNumber: queueNumber)
        _ = try await itemTagRepository.create(shopId: shopId, itemTag: itemTag)
        messageBus.post(message: Message(level: .success, message: .itemTagCreated))
      } catch {
        messageBus.post(
          message: Message(
            level: .error,
            message: error.localizedDescription,
            autoDismiss: false
          )
        )
      }
      
      shouldDismiss = true
    }
  }
}
