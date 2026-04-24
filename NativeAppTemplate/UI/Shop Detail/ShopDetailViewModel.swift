//
//  ShopDetailViewModel.swift
//  NativeAppTemplate
//

import Observation
import SwiftUI

@Observable
@MainActor
final class ShopDetailViewModel {
    var isFetching = true
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
        isFetching
    }

    var isLoggedIn: Bool {
        sessionController.isLoggedIn
    }

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
                messageBus.post(message: Message(error: error))
                shouldDismiss = true
            }
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
