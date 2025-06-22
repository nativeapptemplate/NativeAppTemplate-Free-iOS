//
//  ItemTagListViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
struct ItemTagListViewModelTest {
  var itemTags: [ItemTag] {
    [
      mockItemTag(id: "1", queueNumber: "A01"),
      mockItemTag(id: "2", queueNumber: "A02"),
      mockItemTag(id: "3", queueNumber: "A03"),
      mockItemTag(id: "4", queueNumber: "B01"),
      mockItemTag(id: "5", queueNumber: "B02")
    ]
  }

  let sessionController = TestSessionController()
  let itemTagRepository = TestItemTagRepository(
    itemTagsService: ItemTagsService()
  )
  let messageBus = MessageBus()
  var shop: Shop { mockShop(id: "1", name: "Test Shop") }

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
    #expect(viewModel.itemTags.first?.queueNumber == "A01")
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
    #expect(messageBus.currentMessage!.level == .success)
    #expect(messageBus.currentMessage!.message == .itemTagDeleted)
    #expect(itemTagRepository.itemTags.count == 4) // One deleted
    #expect(itemTagRepository.itemTags.first { $0.id == itemTagIdToDelete } == nil)
  }

  @Test
  func destroyItemTagFailure() async {
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
    #expect(messageBus.currentMessage!.level == .error)
    #expect(messageBus.currentMessage!.autoDismiss == false)
    #expect(messageBus.currentMessage!.message.contains(String.itemTagDeletedError))
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

  private func mockItemTag(id: String = UUID().uuidString, queueNumber: String = "A01") -> ItemTag {
    ItemTag(
      id: id,
      queueNumber: queueNumber
    )
  }

  private func mockShop(id: String = UUID().uuidString, name: String = "Mock Shop") -> Shop {
    Shop(
      id: id,
      name: name,
      description: "This is a mock shop for testing",
      timeZone: "Tokyo",
      itemTagsCount: 10,
      scannedItemTagsCount: 5,
      completedItemTagsCount: 3,
      displayShopServerPath: "https://api.nativeapptemplate.com/display/shops/\(id)?type=server"
    )
  }
}
