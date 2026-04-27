//
//  ShopCreateViewModel.swift
//  NativeAppTemplate
//

import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class ShopCreateViewModel {
    var name: String = ""
    var description: String = ""
    var selectedTimeZone: String = Utility.currentTimeZone()
    var isCreating = false

    private let sessionController: SessionControllerProtocol
    private let shopRepository: ShopRepositoryProtocol
    private(set) var messageBus: MessageBus
    var shouldDismiss: Bool = false

    init(
        sessionController: SessionControllerProtocol,
        shopRepository: ShopRepositoryProtocol,
        messageBus: MessageBus
    ) {
        self.sessionController = sessionController
        self.shopRepository = shopRepository
        self.messageBus = messageBus
    }

    var hasInvalidData: Bool {
        hasInvalidDataName || hasInvalidDataDescription
    }

    var hasInvalidDataName: Bool {
        if Utility.isBlank(name) {
            return true
        }
        if name.count > maximumNameLength {
            return true
        }
        return false
    }

    var hasInvalidDataDescription: Bool {
        description.count > maximumDescriptionLength
    }

    var maximumNameLength: Int {
        NativeAppTemplateConstants.maximumShopNameLength
    }

    var maximumDescriptionLength: Int {
        NativeAppTemplateConstants.maximumShopDescriptionLength
    }

    func validateNameLength() {
        name = String(name.prefix(maximumNameLength))
    }

    func validateDescriptionLength() {
        description = String(description.prefix(maximumDescriptionLength))
    }

    func createShop() {
        Task {
            isCreating = true

            do {
                let shop = Shop(
                    id: "",
                    name: name,
                    description: description,
                    timeZone: selectedTimeZone
                )
                _ = try await shopRepository.create(shop: shop)
                messageBus.post(message: Message(level: .success, message: .shopCreated))
                shouldDismiss = true
            } catch {
                messageBus.post(message: Message(error: error))

                // e.g. Limit shops count error
                guard case NativeAppTemplateAPIError.requestFailed(_, 422, _) = error else {
                    try await sessionController.logout()
                    return
                }

                shouldDismiss = true
            }
        }
    }
}
