//
//  ItemTagEditViewModel.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class ItemTagEditViewModel {
  var queueNumber = ""
  var isFetching = true
  var isUpdating = false
  var shouldDismiss = false
  private(set) var itemTag: ItemTag?
  
  private let itemTagRepository: ItemTagRepositoryProtocol
  private let messageBus: MessageBus
  private let sessionController: SessionControllerProtocol
  private let itemTagId: String
  
  init(
    itemTagRepository: ItemTagRepositoryProtocol,
    messageBus: MessageBus,
    sessionController: SessionControllerProtocol,
    itemTagId: String
  ) {
    self.itemTagRepository = itemTagRepository
    self.messageBus = messageBus
    self.sessionController = sessionController
    self.itemTagId = itemTagId
  }
  
  var isBusy: Bool {
    isFetching || isUpdating
  }
  
  var hasInvalidData: Bool {
    guard let itemTag = itemTag else { return true }
    
    if hasInvalidDataQueueNumber {
      return true
    }
    
    if itemTag.queueNumber == queueNumber {
      return true
    }
    
    return false
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
  
  func reload() {
    fetchItemTagDetail()
  }
  
  func validateQueueNumberLength() {
    queueNumber = String(queueNumber.prefix(maximumQueueNumberLength))
  }
  
  func updateItemTag() {
    Task {
      isUpdating = true
      
      do {
        let itemTag = ItemTag(
          id: itemTagId,
          queueNumber: queueNumber
        )
        
        _ = try await itemTagRepository.update(id: itemTagId, itemTag: itemTag)
        messageBus.post(message: Message(level: .success, message: .itemTagUpdated))
      } catch {
        messageBus.post(message: Message(level: .error, message: error.localizedDescription, autoDismiss: false))
      }
      
      isUpdating = false
      shouldDismiss = true
    }
  }
  
  private func fetchItemTagDetail() {
    Task {
      isFetching = true
      
      do {
        itemTag = try await itemTagRepository.fetchDetail(id: itemTagId)
        if let itemTag = itemTag {
          queueNumber = String(itemTag.queueNumber)
        }
      } catch {
        messageBus.post(message: Message(level: .error, message: error.localizedDescription, autoDismiss: false))
        shouldDismiss = true
      }
      
      isFetching = false
    }
  }
}
