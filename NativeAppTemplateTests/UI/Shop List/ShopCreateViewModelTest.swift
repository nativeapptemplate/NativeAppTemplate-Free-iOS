//
//  ShopCreateViewModelTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

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

    @Test
    func maximumNameLength() {
        let viewModel = ShopCreateViewModel(
            sessionController: sessionController,
            shopRepository: shopRepository,
            messageBus: messageBus
        )

        #expect(viewModel.maximumNameLength == 100)
    }

    @Test
    func maximumDescriptionLength() {
        let viewModel = ShopCreateViewModel(
            sessionController: sessionController,
            shopRepository: shopRepository,
            messageBus: messageBus
        )

        #expect(viewModel.maximumDescriptionLength == 1_000)
    }

    @Test("Name validation", arguments: [
        ("", true),                                  // blank → invalid
        ("a", false),                                // 1 char → valid
        ("Shop Name 1", false),                      // normal → valid
        (String(repeating: "a", count: 100), false), // exactly 100 → valid
        (String(repeating: "a", count: 101), true)   // 101 → invalid
    ])
    func nameValidation(name: String, shouldBeInvalid: Bool) {
        let viewModel = ShopCreateViewModel(
            sessionController: sessionController,
            shopRepository: shopRepository,
            messageBus: messageBus
        )

        viewModel.name = name

        #expect(viewModel.hasInvalidDataName == shouldBeInvalid)
    }

    @Test("Description validation", arguments: [
        ("", false),                                  // empty → valid
        ("Short note.", false),                       // short → valid
        (String(repeating: "x", count: 1000), false), // exactly 1000 → valid
        (String(repeating: "x", count: 1001), true)   // 1001 → invalid
    ])
    func descriptionValidation(description: String, shouldBeInvalid: Bool) {
        let viewModel = ShopCreateViewModel(
            sessionController: sessionController,
            shopRepository: shopRepository,
            messageBus: messageBus
        )

        viewModel.description = description

        #expect(viewModel.hasInvalidDataDescription == shouldBeInvalid)
    }

    @Test
    func validateNameLengthTruncatesCorrectly() {
        let viewModel = ShopCreateViewModel(
            sessionController: sessionController,
            shopRepository: shopRepository,
            messageBus: messageBus
        )

        viewModel.name = String(repeating: "a", count: 100) + "EXTRA"
        viewModel.validateNameLength()

        #expect(viewModel.name == String(repeating: "a", count: 100))
    }

    @Test
    func validateDescriptionLengthTruncatesCorrectly() {
        let viewModel = ShopCreateViewModel(
            sessionController: sessionController,
            shopRepository: shopRepository,
            messageBus: messageBus
        )

        viewModel.description = String(repeating: "x", count: 1500)
        viewModel.validateDescriptionLength()

        #expect(viewModel.description.count == 1_000)
    }

    @Test
    func createShop() async throws {
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

        let latestShop = try #require(shopRepository.shops.last)

        let message = Strings.shopCreated

        #expect(viewModel.messageBus.currentMessage?.message == message)
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

        #expect(viewModel.messageBus.currentMessage?.message == "[NATI-2001] \(message) [Status: \(httpResponseCode)]")
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

        #expect(viewModel.messageBus.currentMessage?.message == "[NATI-2001] \(message) [Status: \(httpResponseCode)]")
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
