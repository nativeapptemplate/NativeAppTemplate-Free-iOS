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
            shopId: shopId
        )

        #expect(viewModel.name == "")
        #expect(viewModel.description == "")
        #expect(viewModel.isCreating == false)
        #expect(viewModel.shouldDismiss == false)
        #expect(viewModel.isBusy == false)
    }

    @Test
    func maximumNameLength() {

        let viewModel = ItemTagCreateViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            shopId: shopId
        )

        #expect(viewModel.maximumNameLength == 100)
    }

    @Test
    func maximumDescriptionLength() {
        let viewModel = ItemTagCreateViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            shopId: shopId
        )

        #expect(viewModel.maximumDescriptionLength == 1000)
    }

    @Test("Name validation", arguments: [
        ("", true),                          // blank → invalid
        ("a", false),                        // 1 char → valid (was invalid pre-2A-3)
        ("ab", false),                       // 2 chars → valid
        ("Buy milk 🥛", false),              // unicode + spaces → valid (was invalid pre-2A-3)
        ("Item with !@#$%^&* symbols", false), // symbols → valid (was invalid pre-2A-3)
        (String(repeating: "a", count: 100), false), // exactly 100 → valid
        (String(repeating: "a", count: 101), true)   // 101 → invalid
    ])
    func nameValidation(name: String, shouldBeInvalid: Bool) {

        let viewModel = ItemTagCreateViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            shopId: shopId
        )

        viewModel.name = name

        #expect(viewModel.hasInvalidDataName == shouldBeInvalid)
    }

    @Test("Description validation", arguments: [
        ("", false),                                    // empty → valid
        ("Short note.", false),                         // short → valid
        (String(repeating: "x", count: 1000), false),   // exactly 1000 → valid
        (String(repeating: "x", count: 1001), true)     // 1001 → invalid
    ])
    func descriptionValidation(description: String, shouldBeInvalid: Bool) {
        let viewModel = ItemTagCreateViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            shopId: shopId
        )

        viewModel.description = description

        #expect(viewModel.hasInvalidDataDescription == shouldBeInvalid)
    }

    @Test
    func validateNameLengthTruncatesCorrectly() {

        let viewModel = ItemTagCreateViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            shopId: shopId
        )

        viewModel.name = String(repeating: "a", count: 100) + "EXTRA"
        viewModel.validateNameLength()

        #expect(viewModel.name == String(repeating: "a", count: 100))
    }

    @Test
    func validateDescriptionLengthTruncatesCorrectly() {
        let viewModel = ItemTagCreateViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            shopId: shopId
        )

        viewModel.description = String(repeating: "x", count: 1500)
        viewModel.validateDescriptionLength()

        #expect(viewModel.description.count == 1000)
    }

    @Test
    func createItemTagSuccess() async {
        let viewModel = ItemTagCreateViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            shopId: shopId
        )

        viewModel.name = "Buy milk"
        viewModel.description = "From the corner store."

        let createTask = Task {
            viewModel.createItemTag()
        }
        await createTask.value

        #expect(viewModel.shouldDismiss == true)
        #expect(messageBus.currentMessage != nil)
        #expect(messageBus.currentMessage?.level == .success)
        #expect(messageBus.currentMessage?.message == .itemTagCreated)
        #expect(itemTagRepository.itemTags.count == 1)
        #expect(itemTagRepository.itemTags.first?.name == "Buy milk")
        #expect(itemTagRepository.itemTags.first?.description == "From the corner store.")
    }

    @Test
    func createItemTagFailure() async {
        let message = "Internal server error."
        let httpResponseCode = 500
        itemTagRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

        let viewModel = ItemTagCreateViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            shopId: shopId
        )

        viewModel.name = "Buy milk"

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
            shopId: shopId
        )

        viewModel.name = "Buy milk"

        let createTask = Task {
            viewModel.createItemTag()
        }

        #expect(viewModel.isBusy == viewModel.isCreating)

        await createTask.value
    }
}
