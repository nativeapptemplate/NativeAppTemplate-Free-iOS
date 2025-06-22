//
//  ItemTagEditViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
struct ItemTagEditViewModelTest { // swiftlint:disable:this type_body_length
  let sessionController = TestSessionController()
  let itemTagRepository = TestItemTagRepository(
    itemTagsService: ItemTagsService()
  )
  let messageBus = MessageBus()
  let itemTagId = "test-item-tag-id"

  var testItemTag: ItemTag {
    ItemTag(
      id: itemTagId,
      shopId: "test-shop-id",
      queueNumber: "A01",
      state: .idled,
      scanState: .unscanned,
      createdAt: Date(),
      customerReadAt: nil,
      completedAt: nil,
      shopName: "Test Shop",
      alreadyCompleted: false
    )
  }

  @Test
  func initializesCorrectly() {
    let viewModel = ItemTagEditViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      itemTagId: itemTagId
    )

    #expect(viewModel.queueNumber == "")
    #expect(viewModel.isFetching == true)
    #expect(viewModel.isUpdating == false)
    #expect(viewModel.shouldDismiss == false)
    #expect(viewModel.itemTag == nil)
  }

  @Test
  func maximumQueueNumberLength() {
    sessionController.maximumQueueNumberLength = 6

    let viewModel = ItemTagEditViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      itemTagId: itemTagId
    )

    #expect(viewModel.maximumQueueNumberLength == 6)
  }

  @Test
  func busyState() {
    let viewModel = ItemTagEditViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      itemTagId: itemTagId
    )

    // Initially fetching
    #expect(viewModel.isBusy == true)
    #expect(viewModel.isFetching == true)

    // When updating
    viewModel.isUpdating = true
    #expect(viewModel.isBusy == true)

    viewModel.isFetching = false
    viewModel.isUpdating = false
    #expect(viewModel.isBusy == false)
  }

  @Test
  func reloadFetchesItemTagDetail() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])

    let viewModel = ItemTagEditViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      itemTagId: itemTagId
    )

    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    #expect(viewModel.isFetching == false)
    #expect(viewModel.itemTag != nil)
    #expect(viewModel.itemTag?.id == itemTagId)
    #expect(viewModel.queueNumber == "A01")
  }

  @Test
  func fetchDetailFailure() async {
    let message = "Item tag not found"
    let httpResponseCode = 404
    itemTagRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

    let viewModel = ItemTagEditViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
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

  @Test("Queue number validation", arguments: [
    ("", true), // blank
    ("a", true), // too short
    ("ab", false), // minimum valid
    ("abc", false), // valid
    ("abcd", false), // valid
    ("ab!", true), // non-alphanumeric
    ("a b", true), // contains space
    ("12", false), // numbers are valid
    ("a1", false) // alphanumeric is valid
  ])
  func queueNumberValidation(queueNumber: String, shouldBeInvalid: Bool) async {
    sessionController.maximumQueueNumberLength = 5
    itemTagRepository.setItemTags(itemTags: [testItemTag])

    let viewModel = ItemTagEditViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      itemTagId: itemTagId
    )

    // Load the item tag first
    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    viewModel.queueNumber = queueNumber

    #expect(viewModel.hasInvalidDataQueueNumber == shouldBeInvalid)
  }

  @Test
  func hasInvalidDataWithUnchangedQueueNumber() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])

    let viewModel = ItemTagEditViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      itemTagId: itemTagId
    )

    // Load the item tag first
    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    // Queue number is same as original - should be invalid
    #expect(viewModel.queueNumber == "A01")
    #expect(viewModel.hasInvalidData == true)

    // Change to different valid queue number - should be valid
    viewModel.queueNumber = "B01"
    #expect(viewModel.hasInvalidData == false)

    // Change to invalid queue number - should be invalid
    viewModel.queueNumber = "!"
    #expect(viewModel.hasInvalidData == true)
  }

  @Test
  func validateQueueNumberLengthTruncatesCorrectly() {
    sessionController.maximumQueueNumberLength = 3

    let viewModel = ItemTagEditViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      itemTagId: itemTagId
    )

    viewModel.queueNumber = "ABCDEFGH"
    viewModel.validateQueueNumberLength()

    #expect(viewModel.queueNumber == "ABC")
  }

  @Test
  func updateItemTagSuccess() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])

    let viewModel = ItemTagEditViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      itemTagId: itemTagId
    )

    // Load the item tag first
    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    // Change to new queue number
    viewModel.queueNumber = "B02"

    let updateTask = Task {
      viewModel.updateItemTag()
    }
    await updateTask.value

    #expect(viewModel.isUpdating == false)
    #expect(viewModel.shouldDismiss == true)
    #expect(messageBus.currentMessage != nil)
    #expect(messageBus.currentMessage!.level == .success)
    #expect(messageBus.currentMessage!.message == .itemTagUpdated)

    // Check that repository was updated
    let updatedItemTag = itemTagRepository.findBy(id: itemTagId)
    #expect(updatedItemTag.queueNumber == "B02")
  }

  @Test
  func updateItemTagFailure() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])

    let viewModel = ItemTagEditViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      itemTagId: itemTagId
    )

    // Load the item tag first
    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    // Set error after loading
    let message = "Update failed"
    let httpResponseCode = 500
    itemTagRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

    viewModel.queueNumber = "B02"

    let updateTask = Task {
      viewModel.updateItemTag()
    }
    await updateTask.value

    #expect(viewModel.isUpdating == false)
    #expect(viewModel.shouldDismiss == true)
    #expect(messageBus.currentMessage != nil)
    #expect(messageBus.currentMessage!.level == .error)
    #expect(messageBus.currentMessage!.autoDismiss == false)
  }

  @Test
  func busyStateDuringUpdate() async {
    itemTagRepository.setItemTags(itemTags: [testItemTag])

    let viewModel = ItemTagEditViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      itemTagId: itemTagId
    )

    // Load the item tag first
    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    viewModel.queueNumber = "B02"

    let updateTask = Task {
      viewModel.updateItemTag()
    }

    // Check busy state immediately after starting
    #expect(viewModel.isBusy == viewModel.isUpdating)

    await updateTask.value

    #expect(viewModel.isBusy == false)
    #expect(viewModel.isUpdating == false)
  }

  @Test("Form validation with different maximum lengths", arguments: [2, 4, 6, 8])
  func formValidationWithDifferentMaxLengths(maxLength: Int) async {
    sessionController.maximumQueueNumberLength = maxLength
    itemTagRepository.setItemTags(itemTags: [testItemTag])

    let viewModel = ItemTagEditViewModel(
      itemTagRepository: itemTagRepository,
      messageBus: messageBus,
      sessionController: sessionController,
      itemTagId: itemTagId
    )

    // Load the item tag first
    let reloadTask = Task {
      viewModel.reload()
    }
    await reloadTask.value

    // Test exactly at the limit
    viewModel.queueNumber = String(repeating: "B", count: maxLength)
    #expect(viewModel.hasInvalidDataQueueNumber == false)

    // Test one over the limit
    viewModel.queueNumber = String(repeating: "B", count: maxLength + 1)
    #expect(viewModel.hasInvalidDataQueueNumber == true)

    // Test truncation
    viewModel.validateQueueNumberLength()
    #expect(viewModel.queueNumber.count == maxLength)
    #expect(viewModel.hasInvalidDataQueueNumber == false)
    #expect(viewModel.hasInvalidData == false) // Should be valid since it's different from original
  }
}
