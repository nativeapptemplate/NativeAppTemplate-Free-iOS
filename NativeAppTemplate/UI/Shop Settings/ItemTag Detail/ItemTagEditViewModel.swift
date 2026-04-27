//
//  ItemTagEditViewModel.swift
//  NativeAppTemplate
//

import Observation
import SwiftUI

@Observable
@MainActor
final class ItemTagEditViewModel {
    var name = ""
    var description = ""
    var isFetching = true
    var isUpdating = false
    var shouldDismiss = false
    private(set) var itemTag: ItemTag?

    private let itemTagRepository: ItemTagRepositoryProtocol
    private let messageBus: MessageBus
    private let itemTagId: String

    init(
        itemTagRepository: ItemTagRepositoryProtocol,
        messageBus: MessageBus,
        itemTagId: String
    ) {
        self.itemTagRepository = itemTagRepository
        self.messageBus = messageBus
        self.itemTagId = itemTagId
    }

    var isBusy: Bool {
        isFetching || isUpdating
    }

    var hasInvalidData: Bool {
        guard let itemTag else { return true }

        if hasInvalidDataName {
            return true
        }

        if hasInvalidDataDescription {
            return true
        }

        if itemTag.name == name, itemTag.description == description {
            return true
        }

        return false
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

    func reload() {
        fetchItemTagDetail()
    }

    func validateNameLength() {
        name = String(name.prefix(maximumNameLength))
    }

    func validateDescriptionLength() {
        description = String(description.prefix(maximumDescriptionLength))
    }

    func updateItemTag() {
        Task {
            isUpdating = true

            do {
                let itemTag = ItemTag(
                    id: itemTagId,
                    name: name,
                    description: description
                )

                _ = try await itemTagRepository.update(id: itemTag.id, itemTag: itemTag)
                messageBus.post(message: Message(level: .success, message: .itemTagUpdated))
            } catch {
                messageBus.post(message: Message(error: error))
            }

            isUpdating = false
            shouldDismiss = true
        }
    }

    private func fetchItemTagDetail() {
        Task {
            isFetching = true

            do {
                itemTag = try await itemTagRepository.fetchDetail(id: itemTagId)
                if let itemTag {
                    name = itemTag.name
                    description = itemTag.description
                }
            } catch {
                messageBus.post(message: Message(error: error))
                shouldDismiss = true
            }

            isFetching = false
        }
    }
}
