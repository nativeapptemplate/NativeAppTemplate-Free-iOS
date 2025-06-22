//
//  ShopBasicSettingsViewModel.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class ShopBasicSettingsViewModel {
  var isFetching = true
  var isUpdating = false
  var name = ""
  var description = ""
  var selectedTimeZone = String.defaultTimeZone
  var shouldDismiss: Bool = false
  private(set) var shop: Shop?

  private let sessionController: SessionControllerProtocol
  private let shopRepository: ShopRepositoryProtocol
  private(set) var messageBus: MessageBus
  let shopId: String

  init(
    sessionController: SessionControllerProtocol,
    shopRepository: ShopRepositoryProtocol,
    messageBus: MessageBus,
    shopId: String
  ) {
    self.sessionController = sessionController
    self.shopRepository = shopRepository
    self.messageBus = messageBus
    self.shopId = shopId
  }

  var isBusy: Bool {
    isFetching || isUpdating
  }
  
  var hasInvalidData: Bool {
    if Utility.isBlank(name) {
      return true
    }
    
    guard let shop = shop else { return true }
    
    if shop.name == name &&
        shop.description == description &&
        shop.timeZone == selectedTimeZone {
      return true
    }
    
    return false
  }

  func reload() {
    Task { @MainActor in
      isFetching = true

      do {
        shop = try await shopRepository.fetchDetail(id: shopId)
        
        guard let shop = shop else {
          messageBus.post(message: Message(level: .error, message: "Shop not found", autoDismiss: false))
          shouldDismiss = true
          return
        }
        
        name = shop.name
        description = shop.description
        selectedTimeZone = shop.timeZone

        isFetching = false
      } catch {
        messageBus.post(message: Message(level: .error, message: error.localizedDescription, autoDismiss: false))
        shouldDismiss = true
      }
    }
  }

  func updateShop() {
    Task { @MainActor in
      isUpdating = true

      do {
        let shop = Shop(
          id: shopId,
          name: name,
          description: description,
          timeZone: selectedTimeZone
       )
        _ = try await shopRepository.update(id: shop.id, shop: shop)
        messageBus.post(message: Message(level: .success, message: .basicSettingsUpdated))
      } catch {
        messageBus.post(message: Message(level: .error, message: error.localizedDescription, autoDismiss: false))
      }
      
      isUpdating = false
      shouldDismiss = true
    }
  }
}
