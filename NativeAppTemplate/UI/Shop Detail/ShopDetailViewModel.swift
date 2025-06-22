//
//  ShopDetailViewModel.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class ShopDetailViewModel {
  var isFetching = true
  var isResetting = false
  var isCompleting = false
  var itemTags: [ItemTag] = []
  var shouldDismiss: Bool = false
  var shopId: String
  private(set) var shop: Shop?

  private let sessionController: SessionControllerProtocol
  private let shopRepository: ShopRepositoryProtocol
  private let itemTagRepository: ItemTagRepositoryProtocol
  private let tabViewModel: TabViewModel
  private let mainTab: MainTab
  let messageBus: MessageBus

  init(
    sessionController: SessionControllerProtocol,
    shopRepository: ShopRepositoryProtocol,
    itemTagRepository: ItemTagRepositoryProtocol,
    tabViewModel: TabViewModel,
    mainTab: MainTab,
    messageBus: MessageBus,
    shopId: String
  ) {
    self.sessionController = sessionController
    self.shopRepository = shopRepository
    self.itemTagRepository = itemTagRepository
    self.tabViewModel = tabViewModel
    self.mainTab = mainTab
    self.messageBus = messageBus
    self.shopId = shopId
  }

  var isBusy: Bool {
    isFetching || isResetting || isCompleting
  }

  var isLoggedIn: Bool { sessionController.isLoggedIn }

  func reload() {
    guard sessionController.isLoggedIn else { return }
    fetchShopDetail()
  }

  private func fetchShopDetail() {
    Task {
      isFetching = true

      do {
        shop = try await shopRepository.fetchDetail(id: shopId)
        itemTags = try await itemTagRepository.fetchAll(shopId: shopId)
        isFetching = false
      } catch {
        messageBus.post(
          message: Message(
            level: .error,
            message: error.localizedDescription,
            autoDismiss: false
          )
        )
        shouldDismiss = true
      }
    }
  }

  func completeTag(itemTagId: String) {
    Task {
      isCompleting = true

      do {
        let itemTag = try await itemTagRepository.complete(id: itemTagId)
        if itemTag.alreadyCompleted == true {
          messageBus.post(message: Message(level: .warning, message: .itemTagAlreadyCompleted, autoDismiss: false))
        } else {
          messageBus.post(message: Message(level: .success, message: .itemTagCompleted))
        }
      } catch {
        messageBus.post(
          message: Message(
            level: .error,
            message: "\(String.itemTagCompletedError) \(error.localizedDescription)",
            autoDismiss: false
          )
        )
      }

      isCompleting = false
      reload()
    }
  }

  func resetTag(itemTagId: String) {
    Task {
      isResetting = true

      do {
        _ = try await itemTagRepository.reset(id: itemTagId)
        messageBus.post(message: Message(level: .success, message: .itemTagReset))
      } catch {
        messageBus.post(
          message: Message(
            level: .error,
            message: "\(String.itemTagResetError) \(error.localizedDescription)",
            autoDismiss: false
          )
        )
      }

      isResetting = false
      reload()
    }
  }

  func setTabViewModelShowingDetailViewToTrue() {
    tabViewModel.showingDetailView[mainTab] = true
  }

  func scrollToTopID() -> ScrollToTopID {
    ScrollToTopID(mainTab: mainTab, detail: true)
  }
  
  func createShopSettingsViewModel() -> ShopSettingsViewModel {
    ShopSettingsViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      shopId: shopId
    )
  }
}
