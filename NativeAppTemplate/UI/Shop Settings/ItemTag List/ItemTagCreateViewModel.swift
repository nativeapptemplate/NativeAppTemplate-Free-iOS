//
//  ItemTagCreateViewModel.swift
//  NativeAppTemplate
//

import Observation
import SwiftUI

@Observable
@MainActor
final class ItemTagCreateViewModel {
    var name = ""
    var isCreating = false
    var shouldDismiss = false

    private let itemTagRepository: ItemTagRepositoryProtocol
    private let messageBus: MessageBus
    private let sessionController: SessionControllerProtocol
    private let shopId: String

    init(
        itemTagRepository: ItemTagRepositoryProtocol,
        messageBus: MessageBus,
        sessionController: SessionControllerProtocol,
        shopId: String
    ) {
        self.itemTagRepository = itemTagRepository
        self.messageBus = messageBus
        self.sessionController = sessionController
        self.shopId = shopId
    }

    var isBusy: Bool {
        isCreating
    }

    var hasInvalidData: Bool {
        hasInvalidDataName
    }

    var hasInvalidDataName: Bool {
        if Utility.isBlank(name) {
            return true
        }

        if !name.isAlphanumeric(ignoreDiacritics: true) {
            return true
        }

        if !(name.count >= 2 && name.count <= maximumQueueNumberLength) {
            return true
        }

        return false
    }

    var maximumQueueNumberLength: Int {
        sessionController.maximumQueueNumberLength
    }

    func validateNameLength() {
        name = String(name.prefix(maximumQueueNumberLength))
    }

    func createItemTag() {
        Task {
            isCreating = true

            do {
                let itemTag = ItemTag(name: name)
                _ = try await itemTagRepository.create(shopId: shopId, itemTag: itemTag)
                messageBus.post(message: Message(level: .success, message: .itemTagCreated))
            } catch {
                messageBus.post(message: Message(error: error))
            }

            shouldDismiss = true
        }
    }
}
