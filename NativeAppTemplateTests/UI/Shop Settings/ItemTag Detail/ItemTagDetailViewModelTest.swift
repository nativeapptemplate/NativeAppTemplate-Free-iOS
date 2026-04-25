//
//  ItemTagDetailViewModelTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
@Suite
struct ItemTagDetailViewModelTest {
    let sessionController = TestSessionController()
    let itemTagRepository = TestItemTagRepository(
        itemTagsService: ItemTagsService()
    )
    let messageBus = MessageBus()
    var shop: Shop {
        mockShop(id: "1", name: "Test Shop")
    }

    let itemTagId = "test-item-tag-id"

    var testItemTag: ItemTag {
        ItemTag(
            id: itemTagId,
            shopId: shop.id,
            name: "A01",
            description: "",
            position: nil,
            state: .idled,
            createdAt: Date(),
            completedAt: nil,
            shopName: shop.name
        )
    }

    @Test
    func initializesCorrectly() {
        let viewModel = ItemTagDetailViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop,
            itemTagId: itemTagId
        )

        #expect(viewModel.isShowingEditSheet == false)
        #expect(viewModel.isShowingDeleteConfirmationDialog == false)
        #expect(viewModel.isFetching == true)
        #expect(viewModel.isDeleting == false)
        #expect(viewModel.shouldDismiss == false)
        #expect(viewModel.itemTag == nil)
        #expect(viewModel.shop.id == shop.id)
        #expect(viewModel.itemTagId == itemTagId)
    }

    @Test
    func busyState() {
        let viewModel = ItemTagDetailViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop,
            itemTagId: itemTagId
        )

        #expect(viewModel.isBusy == true)
        #expect(viewModel.isFetching == true)

        viewModel.isFetching = false
        viewModel.isDeleting = true
        #expect(viewModel.isBusy == true)

        viewModel.isDeleting = false
        #expect(viewModel.isBusy == false)
    }

    @Test
    func reloadCallsFetchItemTagDetail() async {
        itemTagRepository.setItemTags(itemTags: [testItemTag])

        let viewModel = ItemTagDetailViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop,
            itemTagId: itemTagId
        )

        let reloadTask = Task {
            viewModel.reload()
        }
        await reloadTask.value

        #expect(viewModel.isFetching == false)
        #expect(viewModel.itemTag != nil)
        #expect(viewModel.itemTag?.id == itemTagId)
        #expect(viewModel.itemTag?.name == "A01")
    }

    @Test
    func fetchItemTagDetailFailure() async {
        let message = "Item tag not found"
        let httpResponseCode = 404
        itemTagRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

        let viewModel = ItemTagDetailViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop,
            itemTagId: itemTagId
        )

        let reloadTask = Task {
            viewModel.reload()
        }
        await reloadTask.value

        #expect(viewModel.isFetching == false)
        #expect(viewModel.shouldDismiss == true)
        #expect(messageBus.currentMessage != nil)
        #expect(messageBus.currentMessage?.level == .error)
        #expect(messageBus.currentMessage?.autoDismiss == false)
    }

    @Test
    func destroyItemTagSuccess() async {
        itemTagRepository.setItemTags(itemTags: [testItemTag])

        let viewModel = ItemTagDetailViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop,
            itemTagId: itemTagId
        )

        let reloadTask = Task {
            viewModel.reload()
        }
        await reloadTask.value

        let destroyTask = Task {
            viewModel.destroyItemTag()
        }
        await destroyTask.value

        #expect(viewModel.shouldDismiss == true)
        #expect(messageBus.currentMessage != nil)
        #expect(messageBus.currentMessage?.level == .success)
        #expect(messageBus.currentMessage?.message == .itemTagDeleted)
        #expect(itemTagRepository.itemTags.count == 0)
    }

    @Test
    func destroyItemTagFailure() async throws {
        itemTagRepository.setItemTags(itemTags: [testItemTag])

        let viewModel = ItemTagDetailViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop,
            itemTagId: itemTagId
        )

        let reloadTask = Task {
            viewModel.reload()
        }
        await reloadTask.value

        let message = "Delete failed"
        let httpResponseCode = 500
        itemTagRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

        let destroyTask = Task {
            viewModel.destroyItemTag()
        }
        await destroyTask.value

        #expect(viewModel.shouldDismiss == true)
        #expect(messageBus.currentMessage != nil)
        #expect(messageBus.currentMessage?.level == .error)
        #expect(messageBus.currentMessage?.autoDismiss == false)
        let errorMessage = try #require(messageBus.currentMessage?.message)
        #expect(errorMessage.contains(String.itemTagDeletedError))
        #expect(itemTagRepository.itemTags.count == 1)
    }

    @Test
    func destroyItemTagWithoutItemTag() async {
        let viewModel = ItemTagDetailViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop,
            itemTagId: itemTagId
        )

        let destroyTask = Task {
            viewModel.destroyItemTag()
        }
        await destroyTask.value

        #expect(viewModel.isDeleting == false)
        #expect(viewModel.shouldDismiss == false)
        #expect(messageBus.currentMessage == nil)
    }

    @Test
    func busyStateDuringDeletion() async {
        itemTagRepository.setItemTags(itemTags: [testItemTag])

        let viewModel = ItemTagDetailViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop,
            itemTagId: itemTagId
        )

        let reloadTask = Task {
            viewModel.reload()
        }
        await reloadTask.value

        let destroyTask = Task {
            viewModel.destroyItemTag()
        }

        #expect(viewModel.isBusy == viewModel.isDeleting)

        await destroyTask.value
    }

    @Test
    func dialogStateManagement() {
        let viewModel = ItemTagDetailViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shop: shop,
            itemTagId: itemTagId
        )

        #expect(viewModel.isShowingEditSheet == false)
        #expect(viewModel.isShowingDeleteConfirmationDialog == false)

        viewModel.isShowingEditSheet = true
        #expect(viewModel.isShowingEditSheet == true)

        viewModel.isShowingDeleteConfirmationDialog = true
        #expect(viewModel.isShowingDeleteConfirmationDialog == true)
    }

    private func mockShop(id: String = UUID().uuidString, name: String = "Mock Shop") -> Shop {
        Shop(
            id: id,
            name: name,
            description: "This is a mock shop for testing",
            timeZone: "Tokyo",
            itemTagsCount: 10,
            scannedItemTagsCount: 5,
            completedItemTagsCount: 3
        )
    }
}
