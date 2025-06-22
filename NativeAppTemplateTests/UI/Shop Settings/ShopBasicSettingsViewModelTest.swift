//
//  ShopBasicSettingsViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
struct ShopBasicSettingsViewModelTest {
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
  let messageBus = MessageBus()
  let shopId = "1"

  let tabViewModel = TabViewModel()
  let mainTab = MainTab.shops

  @Test
  func stateIsInitiallyLoading() {
    let viewModel = ShopBasicSettingsViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      messageBus: messageBus,
      shopId: shopId
    )

    #expect(viewModel.isFetching)
    #expect(viewModel.isBusy)
  }

  @Test("Has invalid data", arguments: ["", "Shop Name 1"])
  func hasInvalidData(name: String) async {
    shopRepository.setShops(shops: shops)

    let viewModel = ShopBasicSettingsViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      messageBus: messageBus,
      shopId: shopId
    )

    // https://stackoverflow.com/a/75618551/1160200
    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    viewModel.name = name
    #expect(viewModel.hasInvalidData == (name == "" ? true : false))
  }

  @Test("Has invalid data when inputting all same data", arguments: ["Shop 1", "New Shop 1"])
  func hasInvalidDataWhenInputtingAllSameData(name: String) async {
    shopRepository.setShops(shops: shops)

    let viewModel = ShopBasicSettingsViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      messageBus: messageBus,
      shopId: shopId
    )

    // https://stackoverflow.com/a/75618551/1160200
    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    viewModel.name = name
    #expect(viewModel.hasInvalidData == (name == "Shop 1" ? true : false))
  }

  @Test
  func reload() async {
    shopRepository.setShops(shops: shops)

    let viewModel = ShopBasicSettingsViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      messageBus: messageBus,
      shopId: shopId
    )

    // https://stackoverflow.com/a/75618551/1160200
    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    let shop = shops.first { $0.id == shopId }!
    #expect(viewModel.name == shop.name)
    #expect(viewModel.isFetching == false)
    #expect(viewModel.isBusy == false)
  }

  @Test
  func reloadFailed() async {
    shopRepository.setShops(shops: shops)
    let message = "Internal server error."
    let httpResponseCode = 500

    shopRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

    let viewModel = ShopBasicSettingsViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      messageBus: messageBus,
      shopId: shopId
    )

    // https://stackoverflow.com/a/75618551/1160200
    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    #expect(viewModel.messageBus.currentMessage!.message == "\(message) [Status: \(httpResponseCode)]")
    #expect(viewModel.shouldDismiss)
  }

  @Test
  func updateShop() async {
    shopRepository.setShops(shops: shops)

    let viewModel = ShopBasicSettingsViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      messageBus: messageBus,
      shopId: shopId
    )

    // https://stackoverflow.com/a/75618551/1160200
    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    let newName = "New Shop Name"
    let newTimeZone = "Osaka"
    let newDescription = "New Shop Name"

    viewModel.name = newName
    viewModel.selectedTimeZone = newTimeZone
    viewModel.description = newDescription

    // https://stackoverflow.com/a/75618551/1160200
    let updateShopTask = Task {
      viewModel.updateShop()
    }
    await updateShopTask.value

    let latestShop = shopRepository.shops.first { $0.id == shopId }!

    #expect(latestShop.name == newName)
    #expect(latestShop.timeZone == newTimeZone)
    #expect(latestShop.description == newDescription)

    let message = String.basicSettingsUpdated

    #expect(viewModel.messageBus.currentMessage!.message == message)
    #expect(viewModel.isUpdating == false)
    #expect(viewModel.isBusy == false)
    #expect(viewModel.shouldDismiss)
  }

  @Test
  func updateShopFailed() async {
    shopRepository.setShops(shops: shops)

    let viewModel = ShopBasicSettingsViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      messageBus: messageBus,
      shopId: shopId
    )

    // https://stackoverflow.com/a/75618551/1160200
    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    let newName = "New Shop Name"
    let newTimeZone = "Osaka"
    let newDescription = "New Shop Name"

    viewModel.name = newName
    viewModel.selectedTimeZone = newTimeZone
    viewModel.description = newDescription

    let message = "Internal server error."
    let httpResponseCode = 500

    shopRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

    // https://stackoverflow.com/a/75618551/1160200
    let updateShopTask = Task {
      viewModel.updateShop()
    }
    await updateShopTask.value

    #expect(viewModel.messageBus.currentMessage!.message == "\(message) [Status: \(httpResponseCode)]")
    #expect(viewModel.isUpdating == false)
    #expect(viewModel.isBusy == false)
    #expect(viewModel.shouldDismiss)
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
