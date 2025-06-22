//
//  ShopCreateViewModel.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class ShopCreateViewModel {
  var name: String = ""
  var description: String = ""
  var selectedTimeZone: String = Utility.currentTimeZone()
  var isCreating = false

  private let sessionController: SessionControllerProtocol
  private let shopRepository: ShopRepositoryProtocol
  private(set) var messageBus: MessageBus
  var shouldDismiss: Bool = false

  init(
    sessionController: SessionControllerProtocol,
    shopRepository: ShopRepositoryProtocol,
    messageBus: MessageBus
  ) {
    self.sessionController = sessionController
    self.shopRepository = shopRepository
    self.messageBus = messageBus
  }

  var hasInvalidData: Bool {
    Utility.isBlank(name)
  }

  func createShop() {
    Task {
      isCreating = true

      do {
        let shop = Shop(
          id: "",
          name: name,
          description: description,
          timeZone: selectedTimeZone
        )
        _ = try await shopRepository.create(shop: shop)
        messageBus.post(message: Message(level: .success, message: .shopCreated))
        shouldDismiss = true
      } catch {
        messageBus.post(message: Message(level: .error, message: error.localizedDescription, autoDismiss: false))

        // e.g. Limit shops count error
        guard case NativeAppTemplateAPIError.requestFailed(_, 422, _) = error else {
          try await sessionController.logout()
          return
        }

        shouldDismiss = true
      }
    }
  }
}
