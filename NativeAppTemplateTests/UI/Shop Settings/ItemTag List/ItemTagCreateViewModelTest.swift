//
//  ItemTagCreateViewModelTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
@Suite
struct ItemTagCreateViewModelTest {
    let sessionController = TestSessionController()
    let itemTagRepository = TestItemTagRepository(
        itemTagsService: ItemTagsService()
    )
    let messageBus = MessageBus()
    let shopId = "test-shop-id"

    @Test
    func initializesCorrectly() {
        let viewModel = ItemTagCreateViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shopId: shopId
        )

        #expect(viewModel.name == "")
        #expect(viewModel.isCreating == false)
        #expect(viewModel.shouldDismiss == false)
        #expect(viewModel.isBusy == false)
    }

    @Test
    func maximumQueueNumberLength() {
        sessionController.maximumQueueNumberLength = 5

        let viewModel = ItemTagCreateViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shopId: shopId
        )

        #expect(viewModel.maximumQueueNumberLength == 5)
    }

    @Test("Queue number validation - invalid cases", arguments: [
        ("", true), // blank
        ("a", true), // too short
        ("ab", false), // minimum valid
        ("abc", false), // valid
        ("abcd", false), // valid
        ("abcde", false), // maximum valid (assuming max length 5)
        ("abcdef", true), // too long (will be truncated but still invalid in this test)
        ("ab!", true), // non-alphanumeric
        ("a b", true), // contains space
        ("12", false), // numbers are valid
        ("a1", false) // alphanumeric is valid
    ])
    func queueNumberValidation(queueNumber: String, shouldBeInvalid: Bool) {
        sessionController.maximumQueueNumberLength = 5

        let viewModel = ItemTagCreateViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shopId: shopId
        )

        viewModel.name = queueNumber

        #expect(viewModel.hasInvalidDataName == shouldBeInvalid)
        #expect(viewModel.hasInvalidData == shouldBeInvalid)
    }

    @Test
    func validateQueueNumberLengthTruncatesCorrectly() {
        sessionController.maximumQueueNumberLength = 4

        let viewModel = ItemTagCreateViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shopId: shopId
        )

        viewModel.name = "abcdefgh"
        viewModel.validateNameLength()

        #expect(viewModel.name == "abcd")
    }

    @Test
    func createItemTagSuccess() async {
        let viewModel = ItemTagCreateViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shopId: shopId
        )

        viewModel.name = "ABC1"

        let createTask = Task {
            viewModel.createItemTag()
        }
        await createTask.value

        #expect(viewModel.shouldDismiss == true)
        #expect(messageBus.currentMessage != nil)
        #expect(messageBus.currentMessage?.level == .success)
        #expect(messageBus.currentMessage?.message == .itemTagCreated)
        #expect(itemTagRepository.itemTags.count == 1)
        #expect(itemTagRepository.itemTags.first?.name == "ABC1")
    }

    @Test
    func createItemTagFailure() async {
        let message = "Internal server error."
        let httpResponseCode = 500
        itemTagRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

        let viewModel = ItemTagCreateViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shopId: shopId
        )

        viewModel.name = "ABC1"

        let createTask = Task {
            viewModel.createItemTag()
        }
        await createTask.value

        #expect(viewModel.shouldDismiss == true)
        #expect(messageBus.currentMessage != nil)
        #expect(messageBus.currentMessage?.level == .error)
        #expect(messageBus.currentMessage?.autoDismiss == false)
        #expect(itemTagRepository.itemTags.count == 0)
    }

    @Test
    func busyStateDuringCreation() async {
        let viewModel = ItemTagCreateViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shopId: shopId
        )

        viewModel.name = "ABC1"

        let createTask = Task {
            viewModel.createItemTag()
        }

        // Check busy state immediately after starting
        #expect(viewModel.isBusy == viewModel.isCreating)

        await createTask.value
    }

    @Test("Form validation with different maximum lengths", arguments: [2, 4, 6, 8])
    func formValidationWithDifferentMaxLengths(maxLength: Int) {
        sessionController.maximumQueueNumberLength = maxLength

        let viewModel = ItemTagCreateViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            sessionController: sessionController,
            shopId: shopId
        )

        // Test exactly at the limit
        viewModel.name = String(repeating: "A", count: maxLength)
        #expect(viewModel.hasInvalidData == false)

        // Test one over the limit
        viewModel.name = String(repeating: "A", count: maxLength + 1)
        #expect(viewModel.hasInvalidData == true)

        // Test truncation
        viewModel.validateNameLength()
        #expect(viewModel.name.count == maxLength)
        #expect(viewModel.hasInvalidData == false)
    }
}
