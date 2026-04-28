//
//  ItemTagListViewModelTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
@Suite
struct ItemTagListViewModelTest {
    var itemTags: [ItemTag] {
        [
            mockItemTag(id: "1", name: "A01"),
            mockItemTag(id: "2", name: "A02"),
            mockItemTag(id: "3", name: "A03"),
            mockItemTag(id: "4", name: "B01"),
            mockItemTag(id: "5", name: "B02")
        ]
    }

    let sessionController = TestSessionController()
    let itemTagRepository = TestItemTagRepository(
        itemTagsService: ItemTagsService()
    )
    let messageBus = MessageBus()
    var shop: Shop {
        mockShop(id: "1", name: "Test Shop")
    }

    @Test
    func initializesCorrectly() {
        let viewModel = ItemTagListViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop
        )

        #expect(viewModel.isShowingCreateSheet == false)
        #expect(viewModel.isDeleting == false)
        #expect(viewModel.isShowingDeleteConfirmationDialog == false)
        #expect(viewModel.isBusy == false)
        #expect(viewModel.shop.id == shop.id)
    }

    @Test
    func stateReflectsRepository() {
        itemTagRepository.state = .loading

        let viewModel = ItemTagListViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop
        )

        #expect(viewModel.state == .loading)

        itemTagRepository.state = .hasData
        #expect(viewModel.state == .hasData)

        itemTagRepository.state = .failed
        #expect(viewModel.state == .failed)
    }

    @Test
    func itemTagsReflectRepository() {
        itemTagRepository.setItemTags(itemTags: itemTags)

        let viewModel = ItemTagListViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop
        )

        #expect(viewModel.itemTags.count == 5)
        #expect(viewModel.itemTags.first?.name == "A01")
        #expect(viewModel.isEmpty == false)
    }

    @Test
    func isEmptyWhenNoItemTags() {
        itemTagRepository.setItemTags(itemTags: [])

        let viewModel = ItemTagListViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop
        )

        #expect(viewModel.isEmpty == true)
        #expect(viewModel.itemTags.isEmpty == true)
    }

    @Test
    func reloadCallsRepositoryWithShopId() {
        itemTagRepository.paginationMeta = PaginationMeta(
            currentPage: 1, totalPages: 3, totalCount: 55, limit: 20
        )

        let viewModel = ItemTagListViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop
        )

        // Initially should be .initial
        #expect(itemTagRepository.state == .initial)

        viewModel.reload()

        // After reload, state should change to .hasData (success case)
        #expect(itemTagRepository.state == .hasData)

        // Verify paginationMeta is accessible through viewModel
        #expect(viewModel.paginationMeta?.currentPage == 1)
        #expect(viewModel.paginationMeta?.totalPages == 3)
    }

    @Test
    func hasMorePagesReflectsPaginationMeta() {
        let viewModel = ItemTagListViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop
        )

        // No pagination meta — should not have more pages
        #expect(viewModel.hasMorePages == false)

        // Set pagination meta with more pages
        itemTagRepository.paginationMeta = PaginationMeta(
            currentPage: 1, totalPages: 3, totalCount: 55, limit: 20
        )
        #expect(viewModel.hasMorePages == true)

        // Set pagination meta on last page
        itemTagRepository.paginationMeta = PaginationMeta(
            currentPage: 3, totalPages: 3, totalCount: 55, limit: 20
        )
        #expect(viewModel.hasMorePages == false)
    }

    @Test
    func isLoadingMoreReflectsRepository() {
        let viewModel = ItemTagListViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop
        )

        #expect(viewModel.isLoadingMore == false)

        itemTagRepository.isLoadingMore = true
        #expect(viewModel.isLoadingMore == true)

        itemTagRepository.isLoadingMore = false
        #expect(viewModel.isLoadingMore == false)
    }

    @Test
    func loadMoreCallsRepository() {
        itemTagRepository.paginationMeta = PaginationMeta(
            currentPage: 1, totalPages: 3, totalCount: 55, limit: 20
        )

        let viewModel = ItemTagListViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop
        )

        #expect(viewModel.hasMorePages == true)

        viewModel.loadMore()

        // loadNextPage was called (isLoadingMore toggled back to false in test double)
        #expect(itemTagRepository.isLoadingMore == false)
    }

    @Test
    func reloadAfterDestroyResetsToPage1() async {
        itemTagRepository.setItemTags(itemTags: itemTags)
        itemTagRepository.paginationMeta = PaginationMeta(
            currentPage: 2, totalPages: 3, totalCount: 55, limit: 20
        )

        let viewModel = ItemTagListViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop
        )

        let destroyTask = Task {
            viewModel.destroyItemTag(itemTagId: "1")
        }
        await destroyTask.value

        // After destroy, reload is called which resets state
        #expect(itemTagRepository.state == .hasData)
    }

    @Test
    func reloadWithError() {
        let message = "Network error"
        let httpResponseCode = 500
        itemTagRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

        let viewModel = ItemTagListViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop
        )

        viewModel.reload()

        #expect(itemTagRepository.state == .failed)
    }

    @Test
    func destroyItemTagSuccess() async {
        itemTagRepository.setItemTags(itemTags: itemTags)

        let viewModel = ItemTagListViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop
        )

        let itemTagIdToDelete = "1"

        let destroyTask = Task {
            viewModel.destroyItemTag(itemTagId: itemTagIdToDelete)
        }
        await destroyTask.value

        #expect(viewModel.isDeleting == false)
        #expect(messageBus.currentMessage != nil)
        #expect(messageBus.currentMessage?.level == .success)
        #expect(messageBus.currentMessage?.message == .itemTagDeleted)
        #expect(itemTagRepository.itemTags.count == 4) // One deleted
        #expect(itemTagRepository.itemTags.first { $0.id == itemTagIdToDelete } == nil)
    }

    @Test
    func destroyItemTagFailure() async throws {
        itemTagRepository.setItemTags(itemTags: itemTags)
        let message = "Delete failed"
        let httpResponseCode = 500
        itemTagRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

        let viewModel = ItemTagListViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop
        )

        let destroyTask = Task {
            viewModel.destroyItemTag(itemTagId: "1")
        }
        await destroyTask.value

        #expect(viewModel.isDeleting == false)
        #expect(messageBus.currentMessage != nil)
        #expect(messageBus.currentMessage?.level == .error)
        #expect(messageBus.currentMessage?.autoDismiss == false)
        let errorMessage = try #require(messageBus.currentMessage?.message)
        #expect(errorMessage.contains(String.itemTagDeletedError))
        #expect(itemTagRepository.itemTags.count == 5) // Nothing deleted
    }

    @Test
    func busyStateDuringDeletion() async {
        itemTagRepository.setItemTags(itemTags: itemTags)

        let viewModel = ItemTagListViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop
        )

        let destroyTask = Task {
            viewModel.destroyItemTag(itemTagId: "1")
        }

        // Check busy state immediately after starting
        #expect(viewModel.isBusy == viewModel.isDeleting)

        await destroyTask.value

        #expect(viewModel.isBusy == false)
        #expect(viewModel.isDeleting == false)
    }

    @Test
    func dialogStateManagement() {
        let viewModel = ItemTagListViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop
        )

        // Test initial state
        #expect(viewModel.isShowingCreateSheet == false)
        #expect(viewModel.isShowingDeleteConfirmationDialog == false)

        // Test state changes
        viewModel.isShowingCreateSheet = true
        #expect(viewModel.isShowingCreateSheet == true)

        viewModel.isShowingDeleteConfirmationDialog = true
        #expect(viewModel.isShowingDeleteConfirmationDialog == true)
    }

    private func mockItemTag(id: String = UUID().uuidString, name: String = "A01") -> ItemTag {
        ItemTag(
            id: id,
            name: name
        )
    }

    private func mockShop(id: String = UUID().uuidString, name: String = "Mock Shop") -> Shop {
        Shop(
            id: id,
            name: name,
            description: "This is a mock shop for testing",
            timeZone: "Tokyo",
            itemTagsCount: 10,
            completedItemTagsCount: 3
        )
    }
}
