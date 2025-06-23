//
//  ShopListViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
struct ShopListViewModelTest {
  var shops: [Shop] {
    [
      mockShop(id: "1", name: "Shop 1"),
      mockShop(id: "2", name: "Shop 2"),
      mockShop(id: "3", name: "Shop 3"),
      mockShop(id: "4", name: "Shop 4"),
      mockShop(id: "5", name: "Shop 5")
    ]
  }

  let sessionController = TestSessionController()
  let shopRepository = TestShopRepository(
    shopsService: ShopsService()
  )
  let itemTagRepository = TestItemTagRepository(
    itemTagsService: ItemTagsService()
  )
  let tabViewModel = TabViewModel()
  let mainTab = MainTab.shops
  let messageBus = MessageBus()

  @Test
  func leftInShopSlots() {
    shopRepository.limitCount = 5
    shopRepository.createdShopsCount = 2

    let viewModel = ShopListViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab
    )

    #expect(viewModel.leftInShopSlots == 3)
  }

  @Test("Should pop to root view", arguments: [false, true])
  func shouldPopToRootView(shouldPopToRootView: Bool) {
    sessionController.shouldPopToRootView = shouldPopToRootView

    shopRepository.setShops(shops: shops)

    let viewModel = ShopListViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab
    )

    viewModel.reload()

    #expect(viewModel.shouldPopToRootView == shouldPopToRootView)
  }

  @Test
  func reload() {
    shopRepository.setShops(shops: shops)

    let viewModel = ShopListViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab
    )

    viewModel.reload()

    #expect(viewModel.shops.count == 5)
  }

  @Test
  func reloadFailed() {
    shopRepository.setShops(shops: shops)
    shopRepository.error = NativeAppTemplateAPIError.requestFailed(nil, 422, nil)

    let viewModel = ShopListViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab
    )

    viewModel.reload()

    #expect(viewModel.state == .failed)
  }

  @Test
  func showCreateView() {
    let viewModel = ShopListViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab
    )

    #expect(viewModel.isShowingCreateSheet == false)

    viewModel.showCreateView()

    #expect(viewModel.isShowingCreateSheet == true)

    viewModel.showCreateView()

    #expect(viewModel.isShowingCreateSheet == false)
  }

  @Test
  func setTabViewModelShowingDetailViewToFalse() {
    tabViewModel.showingDetailView[mainTab] = true

    let viewModel = ShopListViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab
    )

    viewModel.setTabViewModelShowingDetailViewToFalse()

    #expect(tabViewModel.showingDetailView[mainTab] == false)
  }

  @Test
  func scrollToTopID() {
    let viewModel = ShopListViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab
    )

    let scrollToTopID = viewModel.scrollToTopID()

    #expect(scrollToTopID == ScrollToTopID(mainTab: mainTab, detail: false))
  }

  @Test
  func repositoryProperties() {
    shopRepository.setShops(shops: shops)
    shopRepository.limitCount = 10
    shopRepository.createdShopsCount = 5

    let viewModel = ShopListViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab
    )

    viewModel.reload()

    #expect(viewModel.shops.count == 5)
    #expect(viewModel.limitCount == 10)
    #expect(viewModel.createdShopsCount == 5)
    #expect(viewModel.isEmpty == false)
    #expect(viewModel.leftInShopSlots == 5)
  }

  @Test
  func emptyState() {
    shopRepository.setShops(shops: [])

    let viewModel = ShopListViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab
    )

    viewModel.reload()

    #expect(viewModel.shops.isEmpty == true)
    #expect(viewModel.isEmpty == true)
  }

  private func mockShop(id: String = UUID().uuidString, name: String = "Mock Shop") -> Shop {
    Shop(
      id: id,
      name: name,
      description: "This is a mock shop for testing",
      timeZone: "Tokyo",
      itemTagsCount: 10,
      scannedItemTagsCount: 5,
      completedItemTagsCount: 3,
      displayShopServerPath: "https://api.nativeapptemplate.com/display/shops/\(id)?type=server"
    )
  }
}
