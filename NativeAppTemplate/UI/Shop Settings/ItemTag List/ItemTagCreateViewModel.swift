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
    var description = ""
    var isCreating = false
    var shouldDismiss = false

    private let itemTagRepository: ItemTagRepositoryProtocol
    private let messageBus: MessageBus
    private let shopId: String

    init(
        itemTagRepository: ItemTagRepositoryProtocol,
        messageBus: MessageBus,
        shopId: String
    ) {
        self.itemTagRepository = itemTagRepository
        self.messageBus = messageBus
        self.shopId = shopId
    }

    var isBusy: Bool {
        isCreating
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
        NativeAppTemplateConstants.maximumItemTagNameLength
    }

    var maximumDescriptionLength: Int {
        NativeAppTemplateConstants.maximumItemTagDescriptionLength
    }

    func validateNameLength() {
        name = String(name.prefix(maximumNameLength))
    }

    func validateDescriptionLength() {
        description = String(description.prefix(maximumDescriptionLength))
    }

    func createItemTag() {
        Task {
            isCreating = true

            do {
                let itemTag = ItemTag(name: name, description: description)
                _ = try await itemTagRepository.create(shopId: shopId, itemTag: itemTag)
                messageBus.post(message: Message(level: .success, message: Strings.itemTagCreated))
            } catch {
                messageBus.post(message: Message(error: error))
            }

            shouldDismiss = true
        }
    }
}
