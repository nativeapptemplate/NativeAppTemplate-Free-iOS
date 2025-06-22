//
//  ShopCreateViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
struct ShopCreateViewModelTest {
  let sessionController = TestSessionController()
  let shopRepository = TestShopRepository(
    shopsService: ShopsService()
  )
  let messageBus = MessageBus()

  @Test
  func stateIsInitiallyNotLoading() {
    let viewModel = ShopCreateViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      messageBus: messageBus
    )

    #expect(viewModel.isCreating == false)
  }

  @Test("Has invalid data", arguments: ["", "Shop Name 1"])
  func hasInvalidData(name: String) {
    let viewModel = ShopCreateViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      messageBus: messageBus
    )

    viewModel.name = name
    #expect(viewModel.hasInvalidData == (name == "" ? true : false))
  }

  @Test
  func createShop() async {
    let viewModel = ShopCreateViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      messageBus: messageBus
    )

    let createdShopsCount = shopRepository.createdShopsCount

    let newName = "New Shop Name"
    let newTimeZone = "Osaka"
    let newDescription = "New Shop Description"

    viewModel.name = newName
    viewModel.selectedTimeZone = newTimeZone
    viewModel.description = newDescription

    // https://stackoverflow.com/a/75618551/1160200
    let createShopTask = Task {
      viewModel.createShop()
    }
    await createShopTask.value

    let latestShop = shopRepository.shops.last!

    let message = String.shopCreated

    #expect(viewModel.messageBus.currentMessage!.message == message)
    #expect(viewModel.isCreating)
    #expect(latestShop.name == newName)
    #expect(latestShop.timeZone == newTimeZone)
    #expect(latestShop.description == newDescription)
    #expect(shopRepository.shops.count == createdShopsCount + 1)
    #expect(viewModel.shouldDismiss)
  }

  @Test
  func createShopFailed() async {
    let viewModel = ShopCreateViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      messageBus: messageBus
    )

    let createdShopsCount = shopRepository.createdShopsCount

    let newName = "New Shop Name"
    let newTimeZone = "Osaka"
    let newDescription = "New Shop Description"

    viewModel.name = newName
    viewModel.selectedTimeZone = newTimeZone
    viewModel.description = newDescription

    let message = "You can create up to 99 shops across all organizations."
    let httpResponseCode = 422

    shopRepository.error = NativeAppTemplateAPIError.requestFailed(nil, 422, message)

    // https://stackoverflow.com/a/75618551/1160200
    let createShopTask = Task {
      viewModel.createShop()
    }
    await createShopTask.value

    #expect(viewModel.messageBus.currentMessage!.message == "\(message) [Status: \(httpResponseCode)]")
    #expect(viewModel.isCreating)
    #expect(shopRepository.shops.count == createdShopsCount)
    #expect(viewModel.shouldDismiss)
  }

  @Test
  func createShopFailedNot422() async {
    let viewModel = ShopCreateViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      messageBus: messageBus
    )

    let createdShopsCount = shopRepository.createdShopsCount

    let newName = "New Shop Name"
    let newTimeZone = "Osaka"
    let newDescription = "New Shop Description"

    viewModel.name = newName
    viewModel.selectedTimeZone = newTimeZone
    viewModel.description = newDescription

    let message = "Internal server error."
    let httpResponseCode = 500

    shopRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

    // https://stackoverflow.com/a/75618551/1160200
    let createShopTask = Task {
      viewModel.createShop()
    }
    await createShopTask.value

    #expect(viewModel.messageBus.currentMessage!.message == "\(message) [Status: \(httpResponseCode)]")
    #expect(viewModel.isCreating)
    #expect(shopRepository.shops.count == createdShopsCount)
    #expect(viewModel.shouldDismiss == false)
  }

  @Test
  func initialValues() {
    let viewModel = ShopCreateViewModel(
      sessionController: sessionController,
      shopRepository: shopRepository,
      messageBus: messageBus
    )

    #expect(viewModel.name == "")
    #expect(viewModel.description == "")
    #expect(viewModel.selectedTimeZone == Utility.currentTimeZone())
    #expect(viewModel.shouldDismiss == false)
  }
}
