//
//  ItemTagDetailViewModel.swift
//  NativeAppTemplate
//

import Observation
import SwiftUI

@Observable
@MainActor
final class ItemTagDetailViewModel {
    var isShowingEditSheet = false
    var isShowingDeleteConfirmationDialog = false
    var isFetching = true
    var isDeleting = false
    var shouldDismiss = false
    private(set) var itemTag: ItemTag?

    let itemTagRepository: ItemTagRepositoryProtocol
    let messageBus: MessageBus
    let sessionController: SessionControllerProtocol
    let shop: Shop
    let itemTagId: String

    init(
        itemTagRepository: ItemTagRepositoryProtocol,
        messageBus: MessageBus,
        sessionController: SessionControllerProtocol,
        shop: Shop,
        itemTagId: String
    ) {
        self.itemTagRepository = itemTagRepository
        self.messageBus = messageBus
        self.sessionController = sessionController
        self.shop = shop
        self.itemTagId = itemTagId
    }

    var isBusy: Bool {
        isFetching || isDeleting
    }

    func reload() {
        fetchItemTagDetail()
    }

    func destroyItemTag() {
        guard let itemTag else { return }

        Task {
            isDeleting = true

            do {
                try await itemTagRepository.destroy(id: itemTag.id)
                messageBus.post(message: Message(level: .success, message: .itemTagDeleted))
            } catch {
                messageBus.post(message: Message(
                    level: .error,
                    message: "\(String.itemTagDeletedError) \(error.codedDescription)",
                    autoDismiss: false
                ))
            }

            shouldDismiss = true
        }
    }

    private func fetchItemTagDetail() {
        Task {
            do {
                isFetching = true
                itemTag = try await itemTagRepository.fetchDetail(id: itemTagId)
            } catch {
                messageBus.post(message: Message(error: error))
                shouldDismiss = true
            }

            isFetching = false
        }
    }
}
