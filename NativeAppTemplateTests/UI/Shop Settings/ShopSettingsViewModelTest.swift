//
//  ShopSettingsViewModelTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
@Suite
struct ShopSettingsViewModelTest {
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
    let messageBus = MessageBus()
    let shopId = "1"

    @Test
    func stateIsInitiallyLoading() {
        let viewModel = ShopSettingsViewModel(
            sessionController: sessionController,
            shopRepository: shopRepository,
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            shopId: shopId
        )

        #expect(viewModel.isFetching)
        #expect(viewModel.isBusy)
    }

    @Test
    func reload() async throws {
        shopRepository.setShops(shops: shops)

        let viewModel = ShopSettingsViewModel(
            sessionController: sessionController,
            shopRepository: shopRepository,
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            shopId: shopId
        )

        #expect(viewModel.isFetching == true)
        #expect(viewModel.isBusy)

        // https://stackoverflow.com/a/75618551/1160200
        let reloadTask = Task {
            viewModel.reload()
        }
        await reloadTask.value

        let shop = try #require(shops.first { $0.id == shopId })
        #expect(viewModel.shop == shop)
        #expect(viewModel.isFetching == false)
        #expect(viewModel.isBusy == false)
    }

    @Test
    func reloadFailed() async {
        shopRepository.setShops(shops: shops)

        let message = "Internal server error."
        let httpResponseCode = 500
        shopRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

        let viewModel = ShopSettingsViewModel(
            sessionController: sessionController,
            shopRepository: shopRepository,
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            shopId: shopId
        )

        #expect(viewModel.isFetching == true)
        #expect(viewModel.isBusy)

        // https://stackoverflow.com/a/75618551/1160200
        let reloadTask = Task {
            viewModel.reload()
        }
        await reloadTask.value

        #expect(viewModel.messageBus.currentMessage?.message == "[NATIVEAPPTEMPLATE-2001] \(message) [Status: \(httpResponseCode)]")
        #expect(viewModel.shouldDismiss)
        #expect(viewModel.isFetching == false)
        #expect(viewModel.isBusy == false)
    }

    @Test
    func destroyShop() async throws {
        shopRepository.setShops(shops: shops)

        let viewModel = ShopSettingsViewModel(
            sessionController: sessionController,
            shopRepository: shopRepository,
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            shopId: shopId
        )

        // https://stackoverflow.com/a/75618551/1160200
        let reloadTask = Task {
            viewModel.reload()
        }
        await reloadTask.value

        let shop = try #require(shops.first { $0.id == shopId })
        #expect(viewModel.shop == shop)

        #expect(sessionController.shouldPopToRootView == false)

        // https://stackoverflow.com/a/75618551/1160200
        let destroyShopTask = Task {
            viewModel.destroyShop()
        }
        await destroyShopTask.value

        #expect(viewModel.isDeleting)
        #expect(viewModel.isBusy)
        #expect(sessionController.shouldPopToRootView)
    }

    @Test
    func destroyShopFailed() async throws {
        shopRepository.setShops(shops: shops)

        let viewModel = ShopSettingsViewModel(
            sessionController: sessionController,
            shopRepository: shopRepository,
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            shopId: shopId
        )

        // https://stackoverflow.com/a/75618551/1160200
        let reloadTask = Task {
            viewModel.reload()
        }
        await reloadTask.value

        let shop = try #require(shops.first { $0.id == shopId })
        #expect(viewModel.shop == shop)

        let message = "Internal server error."
        let httpResponseCode = 500
        shopRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

        // https://stackoverflow.com/a/75618551/1160200
        let destroyShopTask = Task {
            viewModel.destroyShop()
        }
        await destroyShopTask.value

        #expect(viewModel.messageBus.currentMessage?.message ==
            "\(Strings.shopDeletedError) [NATIVEAPPTEMPLATE-2001] \(message) [Status: \(httpResponseCode)]")
        #expect(viewModel.isDeleting)
        #expect(viewModel.isBusy)
        #expect(sessionController.userState == .notLoggedIn)
    }

    private func mockShop(id: String = UUID().uuidString, name: String = "Mock Shop") -> Shop {
        Shop(
            id: id,
            name: name,
            description: "This is a mock shop for testing",
            timeZone: "Tokyo",
            itemTagsCount: 10,
            completedItemTagsCount: 3
        )
    }
}
