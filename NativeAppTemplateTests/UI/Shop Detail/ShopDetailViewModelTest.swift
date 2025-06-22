//
//  ShopDetailViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
struct ShopDetailViewModelTest { // swiftlint:disable:this type_body_length
  var shops: [Shop] {
    [
      mockShop(id: "1", name: "Shop 1"),
      mockShop(id: "2", name: "Shop 2")
    ]
  }

  var itemTags: [ItemTag] {
    [
      mockItemTag(id: "1", shopId: "1", queueNumber: "A001"),
      mockItemTag(id: "2", shopId: "1", queueNumber: "A002"),
      mockItemTag(id: "3", shopId: "1", queueNumber: "A003")
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
  let shopId = "1"

  @Test
  func stateIsInitiallyLoading() {
    let viewModel = ShopDetailViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      itemTagRepository: itemTagRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab,
      messageBus: messageBus,
      shopId: shopId
    )

    #expect(viewModel.isFetching)
    #expect(viewModel.isBusy)
  }

  @Test
  func reload() async {
    shopRepository.setShops(shops: shops)
    itemTagRepository.setItemTags(itemTags: itemTags)

    let viewModel = ShopDetailViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      itemTagRepository: itemTagRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab,
      messageBus: messageBus,
      shopId: shopId
    )

    #expect(viewModel.isFetching == true)
    #expect(viewModel.isBusy)

    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    let shop = shops.first { $0.id == shopId }!

    #expect(viewModel.shop == shop)
    #expect(viewModel.itemTags == itemTags)
    #expect(viewModel.isFetching == false)
    #expect(viewModel.isBusy == false)
  }

  @Test
  func reloadFailed() async {
    shopRepository.setShops(shops: shops)
    itemTagRepository.setItemTags(itemTags: itemTags)

    let message = "Internal server error."
    let httpResponseCode = 500
    shopRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

    let viewModel = ShopDetailViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      itemTagRepository: itemTagRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab,
      messageBus: messageBus,
      shopId: shopId
    )

    #expect(viewModel.isFetching == true)
    #expect(viewModel.isBusy)

    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    #expect(viewModel.messageBus.currentMessage!.message == "\(message) [Status: \(httpResponseCode)]")
    #expect(viewModel.shouldDismiss)
  }

  @Test
  func completeTag() async {
    shopRepository.setShops(shops: shops)
    itemTagRepository.setItemTags(itemTags: itemTags)

    let viewModel = ShopDetailViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      itemTagRepository: itemTagRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab,
      messageBus: messageBus,
      shopId: shopId
    )

    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    let shop = shops.first { $0.id == shopId }!
    #expect(viewModel.shop == shop)

    let completeTagTask = Task {
      viewModel.completeTag(itemTagId: itemTags.first!.id)
    }
    await completeTagTask.value

    let message = String.itemTagCompleted

    #expect(viewModel.messageBus.currentMessage!.message == message)
  }

  @Test
  func completeTagWhenAlreadyCompleted() async {
    shopRepository.setShops(shops: shops)
    var modifiedItemTags = itemTags
    modifiedItemTags[0].alreadyCompleted = true

    itemTagRepository.setItemTags(itemTags: modifiedItemTags)

    let viewModel = ShopDetailViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      itemTagRepository: itemTagRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab,
      messageBus: messageBus,
      shopId: shopId
    )

    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    let shop = shops.first { $0.id == shopId }!
    #expect(viewModel.shop == shop)

    let completeTagTask = Task {
      viewModel.completeTag(itemTagId: modifiedItemTags.first!.id)
    }
    await completeTagTask.value

    let message = String.itemTagAlreadyCompleted

    #expect(viewModel.messageBus.currentMessage!.message == message)
  }

  @Test
  func completeTagFailed() async {
    shopRepository.setShops(shops: shops)
    itemTagRepository.setItemTags(itemTags: itemTags)

    let viewModel = ShopDetailViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      itemTagRepository: itemTagRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab,
      messageBus: messageBus,
      shopId: shopId
    )

    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    let shop = shops.first { $0.id == shopId }!
    #expect(viewModel.shop == shop)

    let message = "Internal server error."
    let httpResponseCode = 500
    itemTagRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

    let completeTagTask = Task {
      viewModel.completeTag(itemTagId: itemTags.first!.id)
    }
    await completeTagTask.value

    #expect(viewModel.messageBus.currentMessage!.message ==
            "\(String.itemTagCompletedError) \(message) [Status: \(httpResponseCode)]")
  }

  @Test
  func resetTag() async {
    shopRepository.setShops(shops: shops)
    itemTagRepository.setItemTags(itemTags: itemTags)

    let viewModel = ShopDetailViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      itemTagRepository: itemTagRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab,
      messageBus: messageBus,
      shopId: shopId
    )

    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    let shop = shops.first { $0.id == shopId }!
    #expect(viewModel.shop == shop)

    let resetTagTask = Task {
      viewModel.resetTag(itemTagId: itemTags.first!.id)
    }
    await resetTagTask.value

    let message = String.itemTagReset

    #expect(viewModel.messageBus.currentMessage!.message == message)
  }

  @Test
  func resetTagFailed() async {
    shopRepository.setShops(shops: shops)
    itemTagRepository.setItemTags(itemTags: itemTags)

    let viewModel = ShopDetailViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      itemTagRepository: itemTagRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab,
      messageBus: messageBus,
      shopId: shopId
    )

    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    let shop = shops.first { $0.id == shopId }!
    #expect(viewModel.shop == shop)

    let message = "Internal server error."
    let httpResponseCode = 500
    itemTagRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

    let resetTagTask = Task {
      viewModel.resetTag(itemTagId: itemTags.first!.id)
    }
    await resetTagTask.value

    #expect(viewModel.messageBus.currentMessage!.message ==
            "\(String.itemTagResetError) \(message) [Status: \(httpResponseCode)]")
  }

  @Test
  func setTabViewModelShowingDetailViewToTrue() {
    tabViewModel.showingDetailView[mainTab] = false

    let viewModel = ShopDetailViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      itemTagRepository: itemTagRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab,
      messageBus: messageBus,
      shopId: shopId
    )

    viewModel.setTabViewModelShowingDetailViewToTrue()

    #expect(tabViewModel.showingDetailView[mainTab] == true)
  }

  @Test
  func scrollToTopID() {
    let viewModel = ShopDetailViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      itemTagRepository: itemTagRepository,
      tabViewModel: tabViewModel,
      mainTab: mainTab,
      messageBus: messageBus,
      shopId: shopId
    )

    let scrollToTopID = viewModel.scrollToTopID()

    #expect(scrollToTopID == ScrollToTopID(mainTab: mainTab, detail: true))
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

  private func mockItemTag(
    id: String = UUID().uuidString,
    shopId: String = UUID().uuidString,
    queueNumber: String = "Mock ItemTag"
  ) -> ItemTag {

    let dateString = "2025-05-18 18:00:00 UTC"
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss 'UTC'"
    let date = formatter.date(from: dateString)!

    return ItemTag(
      id: id,
      shopId: shopId,
      queueNumber: queueNumber,
      state: .idled,
      scanState: .unscanned,
      createdAt: date,
      customerReadAt: nil,
      completedAt: nil,
      shopName: "Mock ItemTag",
      alreadyCompleted: false
    )
  }
}
