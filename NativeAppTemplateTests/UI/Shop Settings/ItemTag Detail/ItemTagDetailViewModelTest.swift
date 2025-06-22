//
//  ItemTagDetailViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
struct ItemTagDetailViewModelTest { // swiftlint:disable:this type_body_length
  let sessionController = TestSessionController()
  let itemTagRepository = TestItemTagRepository(
    itemTagsService: ItemTagsService()
  )
  let messageBus = MessageBus()
  let nfcManager = NFCManager()
  var shop: Shop { mockShop(id: "1", name: "Test Shop") }
  let itemTagId = "test-item-tag-id"

  var testItemTag: ItemTag {
    ItemTag(
      id: itemTagId,
      shopId: shop.id,
      queueNumber: "A01",
      state: .idled,
      scanState: .unscanned,
      createdAt: Date(),
      customerReadAt: nil,
      completedAt: nil,
      shopName: shop.name,
      alreadyCompleted: false
    )
  }

  @Test
  func initializesCorrectly() {
    let viewModel = ItemTagDetailViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      nfcManager: nfcManager,
      shop: shop,
      itemTagId: itemTagId
    )

    #expect(viewModel.isLocked == false)
    #expect(viewModel.isShowingEditSheet == false)
    #expect(viewModel.isShowingDeleteConfirmationDialog == false)
    #expect(viewModel.isFetching == true)
    #expect(viewModel.isGeneratingQrCode == false)
    #expect(viewModel.isDeleting == false)
    #expect(viewModel.customerTagQrCodeImage == nil)
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
      nfcManager: nfcManager,
      shop: shop,
      itemTagId: itemTagId
    )

    // Initially fetching
    #expect(viewModel.isBusy == true)
    #expect(viewModel.isFetching == true)

    // When generating QR code
    viewModel.isGeneratingQrCode = true
    #expect(viewModel.isBusy == true)

    // When deleting
    viewModel.isFetching = false
    viewModel.isGeneratingQrCode = false
    viewModel.isDeleting = true
    #expect(viewModel.isBusy == true)

    // When none are busy
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
      nfcManager: nfcManager,
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
    #expect(viewModel.itemTag?.queueNumber == "A01")
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
      nfcManager: nfcManager,
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
    #expect(messageBus.currentMessage!.level == .error)
    #expect(messageBus.currentMessage!.autoDismiss == false)
  }

  @Test
  func generateCustomerQrCode() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])

    let viewModel = ItemTagDetailViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      nfcManager: nfcManager,
      shop: shop,
      itemTagId: itemTagId
    )

    // Load the item tag first
    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    viewModel.generateCustomerQrCode()

    #expect(viewModel.isGeneratingQrCode == false)
    #expect(viewModel.customerTagQrCodeImage != nil)
  }

  @Test
  func generateCustomerQrCodeWithoutItemTag() {
    let viewModel = ItemTagDetailViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      nfcManager: nfcManager,
      shop: shop,
      itemTagId: itemTagId
    )

    // itemTag is nil
    viewModel.generateCustomerQrCode()

    #expect(viewModel.customerTagQrCodeImage == nil)
  }

  @Test
  func destroyItemTagSuccess() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])

    let viewModel = ItemTagDetailViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      nfcManager: nfcManager,
      shop: shop,
      itemTagId: itemTagId
    )

    // Load the item tag first
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
    #expect(messageBus.currentMessage!.level == .success)
    #expect(messageBus.currentMessage!.message == .itemTagDeleted)
    #expect(itemTagRepository.itemTags.count == 0) // Item should be deleted
  }

  @Test
  func destroyItemTagFailure() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])

    let viewModel = ItemTagDetailViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      nfcManager: nfcManager,
      shop: shop,
      itemTagId: itemTagId
    )

    // Load the item tag first
    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    // Set error after loading
    let message = "Delete failed"
    let httpResponseCode = 500
    itemTagRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

    let destroyTask = Task {
      viewModel.destroyItemTag()
    }
    await destroyTask.value

    #expect(viewModel.shouldDismiss == true)
    #expect(messageBus.currentMessage != nil)
    #expect(messageBus.currentMessage!.level == .error)
    #expect(messageBus.currentMessage!.autoDismiss == false)
    #expect(messageBus.currentMessage!.message.contains(.itemTagDeletedError))
    #expect(itemTagRepository.itemTags.count == 1) // Item should still exist
  }

  @Test
  func destroyItemTagWithoutItemTag() async {
    let viewModel = ItemTagDetailViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      nfcManager: nfcManager,
      shop: shop,
      itemTagId: itemTagId
    )

    // itemTag is nil
    let destroyTask = Task {
      viewModel.destroyItemTag()
    }
    await destroyTask.value

    #expect(viewModel.isDeleting == false)
    #expect(viewModel.shouldDismiss == false)
    #expect(messageBus.currentMessage == nil) // No message should be posted
  }

  @Test
  func busyStateDuringDeletion() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])

    let viewModel = ItemTagDetailViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      nfcManager: nfcManager,
      shop: shop,
      itemTagId: itemTagId
    )

    // Load the item tag first
    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    let destroyTask = Task {
      viewModel.destroyItemTag()
    }

    // Check busy state immediately after starting
    #expect(viewModel.isBusy == viewModel.isDeleting)

    await destroyTask.value
  }

  @Test
  func dialogStateManagement() {
    let viewModel = ItemTagDetailViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      nfcManager: nfcManager,
      shop: shop,
      itemTagId: itemTagId
    )

    // Test initial state
    #expect(viewModel.isShowingEditSheet == false)
    #expect(viewModel.isShowingDeleteConfirmationDialog == false)
    #expect(viewModel.isLocked == false)

    // Test state changes
    viewModel.isShowingEditSheet = true
    #expect(viewModel.isShowingEditSheet == true)

    viewModel.isShowingDeleteConfirmationDialog = true
    #expect(viewModel.isShowingDeleteConfirmationDialog == true)

    viewModel.isLocked = true
    #expect(viewModel.isLocked == true)
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
