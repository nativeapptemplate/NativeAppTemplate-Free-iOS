//
//  ShopSettingsViewModel.swift
//  NativeAppTemplate
//

import Observation
import SwiftUI

@Observable
@MainActor
final class ShopSettingsViewModel {
    var isFetching = true
    var isResetting = false
    var isDeleting = false
    var isShowingResetConfirmationDialog = false
    var isShowingDeleteConfirmationDialog = false
    var shouldDismiss: Bool = false
    private(set) var shop: Shop?

    private let sessionController: SessionControllerProtocol
    private let shopRepository: ShopRepositoryProtocol
    let itemTagRepository: ItemTagRepositoryProtocol
    private(set) var messageBus: MessageBus
    let shopId: String

    init(
        sessionController: SessionControllerProtocol,
        shopRepository: ShopRepositoryProtocol,
        itemTagRepository: ItemTagRepositoryProtocol,
        messageBus: MessageBus,
        shopId: String
    ) {
        self.sessionController = sessionController
        self.shopRepository = shopRepository
        self.itemTagRepository = itemTagRepository
        self.messageBus = messageBus
        self.shopId = shopId
    }

    var isBusy: Bool {
        isFetching || isResetting || isDeleting
    }

    func reload() {
        Task {
            isFetching = true
            do {
                shop = try await shopRepository.fetchDetail(id: shopId)
            } catch {
                messageBus.post(message: Message(error: error))
                shouldDismiss = true
            }
            isFetching = false
        }
    }

    func resetShop() {
        guard let shop else { return }

        Task {
            isResetting = true
            do {
                try await shopRepository.reset(id: shop.id)
                messageBus.post(message: .init(level: .success, message: .shopReset))
            } catch {
                messageBus.post(message: .init(
                    level: .error,
                    message: "\(String.shopResetError) \(error.codedDescription)",
                    autoDismiss: false
                ))
            }
            shouldDismiss = true
        }
    }

    func destroyShop() {
        guard let shop else { return }

        Task {
            isDeleting = true
            do {
                try await shopRepository.destroy(id: shop.id)
                messageBus.post(message: .init(level: .success, message: .shopDeleted))
                sessionController.shouldPopToRootView = true
            } catch {
                messageBus.post(message: .init(
                    level: .error,
                    message: "\(String.shopDeletedError) \(error.codedDescription)",
                    autoDismiss: false
                ))
                try await sessionController.logout()
            }
        }
    }
}
