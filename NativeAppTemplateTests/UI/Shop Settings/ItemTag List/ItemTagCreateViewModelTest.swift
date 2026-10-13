//
//  ItemTagCreateViewModelTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
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

        #expect(viewModel.name.isEmpty)
        #expect(viewModel.description.isEmpty)
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

        viewModel.createItemTag()
        await waitUntil { messageBus.currentMessage != nil }

        #expect(viewModel.shouldDismiss == true)
        #expect(messageBus.currentMessage != nil)
        #expect(messageBus.currentMessage?.level == .success)
        #expect(messageBus.currentMessage?.message == Strings.itemTagCreated)
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

        viewModel.createItemTag()
        await waitUntil { messageBus.currentMessage != nil && !viewModel.isCreating }

        // A failed create keeps the form open with the typed name and lets the user retry
        #expect(viewModel.shouldDismiss == false)
        #expect(viewModel.isCreating == false)
        #expect(viewModel.isBusy == false)
        #expect(viewModel.name == "Buy milk")
        // Message(error:) shows NativeAppTemplateAPIError.requestFailed's codedDescription:
        // "[NATIVEAPPTEMPLATE-2001] <message> [Status: <code>]"
        #expect(messageBus.currentMessage?.message == "[NATIVEAPPTEMPLATE-2001] \(message) [Status: \(httpResponseCode)]")
        #expect(messageBus.currentMessage?.level == .error)
        #expect(messageBus.currentMessage?.autoDismiss == false)
        #expect(itemTagRepository.itemTags.isEmpty)
    }

    @Test
    func busyStateDuringCreation() async {
        let viewModel = ItemTagCreateViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            shopId: shopId
        )

        viewModel.name = "Buy milk"

        itemTagRepository.gate = TestGate()
        viewModel.createItemTag()

        // The repository holds the call, so the work is still in flight
        await waitUntil { itemTagRepository.gate?.isWaiting == true }
        #expect(viewModel.isCreating)
        #expect(viewModel.isBusy)
        itemTagRepository.gate?.open()
        await waitUntil { messageBus.currentMessage != nil }
    }
}
