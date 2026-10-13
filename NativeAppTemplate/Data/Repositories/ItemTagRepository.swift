//
//  ItemTagRepository.swift
//  NativeAppTemplate
//

import SwiftUI

@MainActor @Observable class ItemTagRepository: ItemTagRepositoryProtocol {
    let itemTagsService: ItemTagsService

    var itemTags: [ItemTag] = []
    var state: DataState = .initial
    var paginationMeta: PaginationMeta?
    var isLoadingMore = false
    /// The shop whose pages are on screen or loading
    private var listedShopId: String?
    /// Bumped by every reloadPage, so a page that arrives after another one was
    /// asked for (the user opened another shop meanwhile) is dropped
    private var listGeneration = 0

    required init(itemTagsService: ItemTagsService) {
        self.itemTagsService = itemTagsService
    }

    func reloadPage(shopId: String, page: Int) {
        if Task.isCancelled {
            return
        }

        // A reload of this shop is already on its way
        if state == .loading, listedShopId == shopId {
            return
        }

        // The list keeps showing itemTags while loading, so drop another
        // shop's tags rather than show them under this shop
        if itemTags.contains(where: { $0.shopId != shopId }) {
            itemTags = []
            paginationMeta = nil
        }

        // A next page still loading belongs to the old list and will be dropped
        isLoadingMore = false
        listedShopId = shopId
        listGeneration += 1
        let generation = listGeneration
        state = .loading

        Task { @MainActor in
            do {
                let response = try await itemTagsService.allItemTags(shopId: shopId, page: page)
                guard generation == listGeneration else { return }

                itemTags = response.itemTags
                paginationMeta = response.paginationMeta
                state = .hasData
            } catch {
                guard generation == listGeneration else { return }

                state = .failed
                Failure
                    .fetch(from: Self.self, reason: error.codedDescription)
                    .log()
            }
        }
    }

    func loadNextPage(shopId: String) {
        guard let meta = paginationMeta, meta.hasMorePages else { return }

        if isLoadingMore {
            return
        }

        isLoadingMore = true
        let generation = listGeneration

        Task { @MainActor in
            do {
                let response = try await itemTagsService.allItemTags(shopId: shopId, page: meta.currentPage + 1)
                // The list was reloaded (or another shop opened) meanwhile
                guard generation == listGeneration else { return }

                // A list that shifted since the last page can repeat tags already
                // listed; keep the first occurrence so each id appears once, in order
                let listedIds = Set(itemTags.map(\.id))
                itemTags.append(contentsOf: response.itemTags.filter { !listedIds.contains($0.id) })
                paginationMeta = response.paginationMeta
            } catch {
                Failure
                    .fetch(from: Self.self, reason: error.codedDescription)
                    .log()
            }
            guard generation == listGeneration else { return }

            isLoadingMore = false
        }
    }

    /// For the shop detail, which keeps the tags itself. `itemTags` is the item tag
    /// list's pages, possibly of another shop the user opened while this was loading,
    /// so it is left alone
    func fetchAll(shopId: String) async throws -> [ItemTag] {
        do {
            return try await itemTagsService.allItemTags(shopId: shopId).itemTags
        } catch {
            Failure
                .fetch(from: Self.self, reason: error.codedDescription)
                .log()
            throw error
        }
    }

    func fetchDetail(id: String) async throws -> ItemTag {
        do {
            let itemTag = try await itemTagsService.itemTagDetail(id: id)
            let itemTagIndex = (itemTags.firstIndex { $0.id == itemTag.id })
            if itemTagIndex == nil {
                itemTags.append(itemTag)
            } else {
                itemTags[itemTagIndex!] = itemTag
            }

            return itemTag
        } catch {
            Failure
                .fetch(from: Self.self, reason: error.codedDescription)
                .log()
            throw error
        }
    }

    func create(shopId: String, itemTag: ItemTag) async throws -> ItemTag {
        do {
            return try await itemTagsService.makeItemTag(shopId: shopId, itemTag: itemTag)
        } catch {
            Failure
                .create(from: Self.self, reason: error.codedDescription)
                .log()
            throw error
        }
    }

    func update(id: String, itemTag: ItemTag) async throws -> ItemTag {
        do {
            let updatedItemTag = try await itemTagsService.updateItemTag(id: id, itemTag: itemTag)
            let itemTagIndex = (itemTags.firstIndex { $0.id == updatedItemTag.id })
            if itemTagIndex != nil {
                itemTags[itemTagIndex!] = updatedItemTag
            }

            return updatedItemTag
        } catch {
            Failure
                .update(from: Self.self, reason: error.codedDescription)
                .log()
            throw error
        }
    }

    func destroy(id: String) async throws {
        do {
            try await itemTagsService.destroyItemTag(id: id)
        } catch {
            Failure
                .destroy(from: Self.self, reason: error.codedDescription)
                .log()
            throw error
        }
    }

    func complete(id: String) async throws -> ItemTag {
        do {
            let completedItemTag = try await itemTagsService.completeItemTag(id: id)
            let itemTagIndex = (itemTags.firstIndex { $0.id == completedItemTag.id })
            if itemTagIndex != nil {
                itemTags[itemTagIndex!] = completedItemTag
            }

            return completedItemTag
        } catch {
            // The caller reports the error; the list's own state is unchanged
            Failure
                .update(from: Self.self, reason: error.codedDescription)
                .log()
            throw error
        }
    }

    func idle(id: String) async throws -> ItemTag {
        do {
            let idledItemTag = try await itemTagsService.idleItemTag(id: id)
            let itemTagIndex = (itemTags.firstIndex { $0.id == idledItemTag.id })
            if itemTagIndex != nil {
                itemTags[itemTagIndex!] = idledItemTag
            }

            return idledItemTag
        } catch {
            // The caller reports the error; the list's own state is unchanged
            Failure
                .update(from: Self.self, reason: error.codedDescription)
                .log()
            throw error
        }
    }
}
