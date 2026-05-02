//
//  ItemTagListViewModel.swift
//  NativeAppTemplate
//

import Observation
import SwiftUI

@Observable
@MainActor
final class ItemTagListViewModel {
    var isShowingCreateSheet = false
    var isDeleting = false
    var isShowingDeleteConfirmationDialog = false
    var state: DataState {
        itemTagRepository.state
    }

    var itemTags: [ItemTag] {
        itemTagRepository.itemTags
    }

    var paginationMeta: PaginationMeta? {
        itemTagRepository.paginationMeta
    }

    var isLoadingMore: Bool {
        itemTagRepository.isLoadingMore
    }

    var hasMorePages: Bool {
        paginationMeta?.hasMorePages ?? false
    }

    private let itemTagRepository: ItemTagRepositoryProtocol
    private let messageBus: MessageBus
    private let sessionController: SessionControllerProtocol
    let shop: Shop

    init(
        itemTagRepository: ItemTagRepositoryProtocol,
        messageBus: MessageBus,
        sessionController: SessionControllerProtocol,
        shop: Shop
    ) {
        self.itemTagRepository = itemTagRepository
        self.messageBus = messageBus
        self.sessionController = sessionController
        self.shop = shop
    }

    var isBusy: Bool {
        isDeleting
    }

    var isEmpty: Bool {
        itemTags.isEmpty
    }

    func reload() {
        itemTagRepository.reloadPage(shopId: shop.id, page: 1)
    }

    func loadMore() {
        itemTagRepository.loadNextPage(shopId: shop.id)
    }

    func destroyItemTag(itemTagId: String) {
        Task {
            isDeleting = true

            do {
                try await itemTagRepository.destroy(id: itemTagId)
                messageBus.post(message: Message(level: .success, message: Strings.itemTagDeleted))
                reload()
            } catch {
                messageBus.post(message: Message(
                    level: .error,
                    message: "\(Strings.itemTagDeletedError) \(error.codedDescription)",
                    autoDismiss: false
                ))
            }

            isDeleting = false
        }
    }
}
