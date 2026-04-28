//
//  ItemTagEditViewModelTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
@Suite
struct ItemTagEditViewModelTest {
    let itemTagRepository = TestItemTagRepository(
        itemTagsService: ItemTagsService()
    )
    let messageBus = MessageBus()
    let itemTagId = "test-item-tag-id"

    var testItemTag: ItemTag {
        ItemTag(
            id: itemTagId,
            shopId: "test-shop-id",
            name: "Original",
            description: "Original description",
            position: 1,
            state: .idled,
            createdAt: Date(),
            completedAt: nil,
            shopName: "Test Shop"
        )
    }

    @Test
    func initializesCorrectly() {
        let viewModel = ItemTagEditViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            itemTagId: itemTagId
        )

        #expect(viewModel.name == "")
        #expect(viewModel.description == "")
        #expect(viewModel.isFetching == true)
        #expect(viewModel.isUpdating == false)
        #expect(viewModel.shouldDismiss == false)
        #expect(viewModel.itemTag == nil)
    }

    @Test
    func maximumNameLength() {

        let viewModel = ItemTagEditViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            itemTagId: itemTagId
        )

        #expect(viewModel.maximumNameLength == 100)
    }

    @Test
    func maximumDescriptionLength() {
        let viewModel = ItemTagEditViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            itemTagId: itemTagId
        )

        #expect(viewModel.maximumDescriptionLength == 1000)
    }

    @Test
    func busyState() {
        let viewModel = ItemTagEditViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            itemTagId: itemTagId
        )

        #expect(viewModel.isBusy == true)
        #expect(viewModel.isFetching == true)

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
            itemTagId: itemTagId
        )

        let reloadTask = Task {
            viewModel.reload()
        }
        await reloadTask.value

        #expect(viewModel.isFetching == false)
        #expect(viewModel.itemTag != nil)
        #expect(viewModel.itemTag?.id == itemTagId)
        #expect(viewModel.name == "Original")
        #expect(viewModel.description == "Original description")
    }

    @Test
    func fetchDetailFailure() async {
        let message = "Item tag not found"
        let httpResponseCode = 404
        itemTagRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

        let viewModel = ItemTagEditViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
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

    @Test("Name validation", arguments: [
        ("", true),                                  // blank → invalid
        ("a", false),                                // 1 char → valid
        ("Buy milk 🥛", false),                      // unicode + space → valid
        ("Item with !@#$%^&* symbols", false),       // symbols → valid
        (String(repeating: "x", count: 100), false), // exactly 100 → valid
        (String(repeating: "x", count: 101), true)   // 101 → invalid
    ])
    func nameValidation(name: String, shouldBeInvalid: Bool) async {
        itemTagRepository.setItemTags(itemTags: [testItemTag])

        let viewModel = ItemTagEditViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            itemTagId: itemTagId
        )

        let reloadTask = Task {
            viewModel.reload()
        }
        await reloadTask.value

        viewModel.name = name

        #expect(viewModel.hasInvalidDataName == shouldBeInvalid)
    }

    @Test("Description validation", arguments: [
        ("", false),
        ("Some notes.", false),
        (String(repeating: "x", count: 1000), false),
        (String(repeating: "x", count: 1001), true)
    ])
    func descriptionValidation(description: String, shouldBeInvalid: Bool) async {
        itemTagRepository.setItemTags(itemTags: [testItemTag])

        let viewModel = ItemTagEditViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            itemTagId: itemTagId
        )

        let reloadTask = Task {
            viewModel.reload()
        }
        await reloadTask.value

        viewModel.description = description

        #expect(viewModel.hasInvalidDataDescription == shouldBeInvalid)
    }

    @Test
    func hasInvalidDataChangeDetection() async {
        itemTagRepository.setItemTags(itemTags: [testItemTag])

        let viewModel = ItemTagEditViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            itemTagId: itemTagId
        )

        let reloadTask = Task {
            viewModel.reload()
        }
        await reloadTask.value

        // Both unchanged → invalid (no changes to save)
        #expect(viewModel.name == "Original")
        #expect(viewModel.description == "Original description")
        #expect(viewModel.hasInvalidData == true)

        // Name changed only → valid
        viewModel.name = "Updated"
        #expect(viewModel.hasInvalidData == false)

        // Reset name; description changed only → valid
        viewModel.name = "Original"
        viewModel.description = "Updated description"
        #expect(viewModel.hasInvalidData == false)

        // Both changed → valid
        viewModel.name = "Updated"
        #expect(viewModel.hasInvalidData == false)

        // Name invalid (blank) → invalid regardless of description
        viewModel.name = ""
        #expect(viewModel.hasInvalidData == true)
    }

    @Test
    func validateNameLengthTruncatesCorrectly() {

        let viewModel = ItemTagEditViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            itemTagId: itemTagId
        )

        viewModel.name = String(repeating: "A", count: 100) + "EXTRA"
        viewModel.validateNameLength()

        #expect(viewModel.name == String(repeating: "A", count: 100))
    }

    @Test
    func validateDescriptionLengthTruncatesCorrectly() {
        let viewModel = ItemTagEditViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            itemTagId: itemTagId
        )

        viewModel.description = String(repeating: "x", count: 1500)
        viewModel.validateDescriptionLength()

        #expect(viewModel.description.count == 1000)
    }

    @Test
    func updateItemTagSuccess() async {
        itemTagRepository.setItemTags(itemTags: [testItemTag])

        let viewModel = ItemTagEditViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            itemTagId: itemTagId
        )

        let reloadTask = Task {
            viewModel.reload()
        }
        await reloadTask.value

        viewModel.name = "Updated name"
        viewModel.description = "Updated description"

        let updateTask = Task {
            viewModel.updateItemTag()
        }
        await updateTask.value

        #expect(viewModel.isUpdating == false)
        #expect(viewModel.shouldDismiss == true)
        #expect(messageBus.currentMessage != nil)
        #expect(messageBus.currentMessage?.level == .success)
        #expect(messageBus.currentMessage?.message == Strings.itemTagUpdated)

        let updatedItemTag = itemTagRepository.findBy(id: itemTagId)
        #expect(updatedItemTag.name == "Updated name")
        #expect(updatedItemTag.description == "Updated description")
    }

    @Test
    func updateItemTagFailure() async {
        itemTagRepository.setItemTags(itemTags: [testItemTag])

        let viewModel = ItemTagEditViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            itemTagId: itemTagId
        )

        let reloadTask = Task {
            viewModel.reload()
        }
        await reloadTask.value

        let message = "Update failed"
        let httpResponseCode = 500
        itemTagRepository.error = NativeAppTemplateAPIError.requestFailed(nil, httpResponseCode, message)

        viewModel.name = "Updated"

        let updateTask = Task {
            viewModel.updateItemTag()
        }
        await updateTask.value

        #expect(viewModel.isUpdating == false)
        #expect(viewModel.shouldDismiss == true)
        #expect(messageBus.currentMessage != nil)
        #expect(messageBus.currentMessage?.level == .error)
        #expect(messageBus.currentMessage?.autoDismiss == false)
    }

    @Test
    func busyStateDuringUpdate() async {
        itemTagRepository.setItemTags(itemTags: [testItemTag])

        let viewModel = ItemTagEditViewModel(
            itemTagRepository: itemTagRepository,
            messageBus: messageBus,
            itemTagId: itemTagId
        )

        let reloadTask = Task {
            viewModel.reload()
        }
        await reloadTask.value

        viewModel.name = "Updated"

        let updateTask = Task {
            viewModel.updateItemTag()
        }

        #expect(viewModel.isBusy == viewModel.isUpdating)

        await updateTask.value

        #expect(viewModel.isBusy == false)
        #expect(viewModel.isUpdating == false)
    }
}
