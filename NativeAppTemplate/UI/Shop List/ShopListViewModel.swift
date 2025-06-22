//
//  ShopListViewModel.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class ShopListViewModel {
  var isShowingCreateSheet = false
  
  var state: DataState { shopRepository.state }
  var shops: [Shop] { shopRepository.shops }
  var limitCount: Int { shopRepository.limitCount }
  var createdShopsCount: Int { shopRepository.createdShopsCount }
  var isEmpty: Bool { shopRepository.isEmpty }
  var leftInShopSlots: Int { limitCount - createdShopsCount }
  var shouldPopToRootView: Bool { sessionController.shouldPopToRootView }
  
  let shopRepository: ShopRepositoryProtocol
  let itemTagRepository: ItemTagRepositoryProtocol
  private let sessionController: SessionControllerProtocol
  private let tabViewModel: TabViewModel
  private let mainTab: MainTab
  private let messageBus: MessageBus

  init(
    sessionController: SessionControllerProtocol,
    shopRepository: ShopRepositoryProtocol,
    itemTagRepository: ItemTagRepositoryProtocol,
    tabViewModel: TabViewModel,
    mainTab: MainTab,
    messageBus: MessageBus
  ) {
    self.sessionController = sessionController
    self.shopRepository = shopRepository
    self.itemTagRepository = itemTagRepository
    self.tabViewModel = tabViewModel
    self.mainTab = mainTab
    self.messageBus = messageBus
  }
  
  func reload() {
    shopRepository.reload()
  }
  
  func showCreateView() {
    isShowingCreateSheet.toggle()
  }
  
  func setTabViewModelShowingDetailViewToFalse() {
    tabViewModel.showingDetailView[mainTab] = false
  }
  
  func scrollToTopID() -> ScrollToTopID {
    ScrollToTopID(mainTab: mainTab, detail: false)
  }
}
