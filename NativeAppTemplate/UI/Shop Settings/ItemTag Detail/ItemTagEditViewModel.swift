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
    var isFetching = true
    var isUpdating = false
    var shouldDismiss = false
    private(set) var itemTag: ItemTag?

    private let itemTagRepository: ItemTagRepositoryProtocol
    private let messageBus: MessageBus
    private let sessionController: SessionControllerProtocol
    private let itemTagId: String

    init(
        itemTagRepository: ItemTagRepositoryProtocol,
        messageBus: MessageBus,
        sessionController: SessionControllerProtocol,
        itemTagId: String
    ) {
        self.itemTagRepository = itemTagRepository
        self.messageBus = messageBus
        self.sessionController = sessionController
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

        if itemTag.name == name {
            return true
        }

        return false
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

    func reload() {
        fetchItemTagDetail()
    }

    func validateNameLength() {
        name = String(name.prefix(maximumQueueNumberLength))
    }

    func updateItemTag() {
        Task {
            isUpdating = true

            do {
                let itemTag = ItemTag(
                    id: itemTagId,
                    name: name
                )

                _ = try await itemTagRepository.update(id: itemTagId, itemTag: itemTag)
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
                    name = String(itemTag.name)
                }
            } catch {
                messageBus.post(message: Message(error: error))
                shouldDismiss = true
            }

            isFetching = false
        }
    }
}
