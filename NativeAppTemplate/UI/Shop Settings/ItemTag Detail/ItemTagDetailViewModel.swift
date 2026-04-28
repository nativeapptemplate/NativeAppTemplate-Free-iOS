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
    var isToggling = false
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
        isFetching || isDeleting || isToggling
    }

    func reload() {
        fetchItemTagDetail()
    }

    func completeItemTag() {
        guard let itemTag else { return }

        Task {
            isToggling = true

            do {
                let updated = try await itemTagRepository.complete(id: itemTag.id)
                self.itemTag = updated
            } catch {
                messageBus.post(message: Message(
                    level: .error,
                    message: "\(Strings.itemTagCompletedError) \(error.codedDescription)",
                    autoDismiss: false
                ))
            }

            isToggling = false
        }
    }

    func idleItemTag() {
        guard let itemTag else { return }

        Task {
            isToggling = true

            do {
                let updated = try await itemTagRepository.idle(id: itemTag.id)
                self.itemTag = updated
            } catch {
                messageBus.post(message: Message(
                    level: .error,
                    message: "\(Strings.itemTagIdledError) \(error.codedDescription)",
                    autoDismiss: false
                ))
            }

            isToggling = false
        }
    }

    func destroyItemTag() {
        guard let itemTag else { return }

        Task {
            isDeleting = true

            do {
                try await itemTagRepository.destroy(id: itemTag.id)
                messageBus.post(message: Message(level: .success, message: Strings.itemTagDeleted))
            } catch {
                messageBus.post(message: Message(
                    level: .error,
                    message: "\(Strings.itemTagDeletedError) \(error.codedDescription)",
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
