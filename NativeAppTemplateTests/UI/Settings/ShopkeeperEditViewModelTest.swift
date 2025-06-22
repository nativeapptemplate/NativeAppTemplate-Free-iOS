//
//  ShopkeeperEditViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/20.
//

// swiftlint:disable file_length

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
struct ShopkeeperEditViewModelTest { // swiftlint:disable:this type_body_length
  let signUpRepository = TestSignUpRepository()
  let sessionController = TestSessionController()
  let messageBus = MessageBus()
  let tabViewModel = TabViewModel()

  var testShopkeeper: Shopkeeper {
    Shopkeeper(
      id: "test-shopkeeper-id",
      accountId: "test-account-id",
      personalAccountId: "test-personal-id",
      accountOwnerId: "test-owner-id",
      accountName: "Test Account",
      email: "test@example.com",
      name: "Test User",
      timeZone: "Tokyo",
      uid: "test-uid",
      token: "test-token",
      client: "test-client",
      expiry: "test-expiry"
    )!
  }

  @Test
  func initializesCorrectly() {
    let shopkeeper = testShopkeeper

    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: shopkeeper
    )

    #expect(viewModel.name == "Test User")
    #expect(viewModel.email == "test@example.com")
    #expect(viewModel.selectedTimeZone == "Tokyo")
    #expect(viewModel.isUpdating == false)
    #expect(viewModel.isDeleting == false)
    #expect(viewModel.isShowingDeleteConfirmationDialog == false)
    #expect(viewModel.shouldDismiss == false)
  }

  @Test
  func busyStateReflectsUpdatingAndDeletingStates() {
    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: testShopkeeper
    )

    #expect(viewModel.isBusy == false)

    viewModel.isUpdating = true
    #expect(viewModel.isBusy == true)

    viewModel.isUpdating = false
    viewModel.isDeleting = true
    #expect(viewModel.isBusy == true)

    viewModel.isDeleting = false
    #expect(viewModel.isBusy == false)

    // Both updating and deleting
    viewModel.isUpdating = true
    viewModel.isDeleting = true
    #expect(viewModel.isBusy == true)
  }

  @Test("Email validation", arguments: [
    ("", true), // blank email
    ("invalid", true), // no @ symbol
    ("invalid@", true), // no domain
    ("@invalid.com", true), // no local part
    ("test@example.com", false), // valid email
    ("user.name+tag@example.co.uk", false), // complex valid email
    ("test@", true), // missing domain
    ("test@.com", true), // missing domain name
    ("test @example.com", true) // space in email
  ])
  func emailValidation(email: String, shouldBeInvalid: Bool) {
    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: testShopkeeper
    )

    viewModel.email = email

    #expect(viewModel.hasInvalidDataEmail == shouldBeInvalid)
  }

  @Test("Form validation - blank name", arguments: [
    ("", true), // blank name
    ("   ", true), // whitespace only name
    ("Valid Name", false) // valid name
  ])
  func formValidationBlankName(name: String, shouldBeInvalid: Bool) {
    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: testShopkeeper
    )

    viewModel.name = name
    viewModel.email = "different@example.com" // Make sure data is changed

    #expect(viewModel.hasInvalidData == shouldBeInvalid)
  }

  @Test
  func formValidationWithInvalidEmail() {
    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: testShopkeeper
    )

    viewModel.name = "Valid Name"
    viewModel.email = "invalid-email"

    #expect(viewModel.hasInvalidData == true)
    #expect(viewModel.hasInvalidDataEmail == true)
  }

  @Test
  func formValidationWhenDataUnchanged() {
    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: testShopkeeper
    )

    // Keep all data the same as original shopkeeper
    #expect(viewModel.name == testShopkeeper.name)
    #expect(viewModel.email == testShopkeeper.email)
    #expect(viewModel.selectedTimeZone == testShopkeeper.timeZone)

    #expect(viewModel.hasInvalidData == true) // Should be invalid when unchanged
  }

  @Test
  func formValidationWhenDataChanged() {
    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: testShopkeeper
    )

    viewModel.name = "New Name"
    #expect(viewModel.hasInvalidData == false)

    viewModel.name = testShopkeeper.name // reset name
    viewModel.email = "new@example.com"
    #expect(viewModel.hasInvalidData == false)

    viewModel.email = testShopkeeper.email // reset email
    viewModel.selectedTimeZone = "Osaka"
    #expect(viewModel.hasInvalidData == false)
  }

  @Test
  func updateShopkeeperSuccess() async {
    sessionController.shopkeeper = testShopkeeper

    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: testShopkeeper
    )

    viewModel.name = "Updated Name"
    viewModel.email = "updated@example.com"
    viewModel.selectedTimeZone = "Osaka"

    let updateTask = Task {
      viewModel.updateShopkeeper()
    }
    await updateTask.value

    #expect(viewModel.isUpdating == false)
    #expect(viewModel.shouldDismiss == true)
    #expect(messageBus.currentMessage != nil)
    #expect(messageBus.currentMessage!.level == .success)
  }

  @Test
  func updateShopkeeperWithEmailChangeTriggersReconfirmation() async {
    sessionController.shopkeeper = testShopkeeper

    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: testShopkeeper
    )

    viewModel.email = "newemail@example.com" // Email change

    let updateTask = Task {
      viewModel.updateShopkeeper()
    }
    await updateTask.value

    #expect(viewModel.shouldDismiss == true)
    #expect(messageBus.currentMessage != nil)
    #expect(messageBus.currentMessage!.level == .success)
    #expect(messageBus.currentMessage!.message == .reconfirmDescription)
    #expect(messageBus.currentMessage!.autoDismiss == false)
    #expect(sessionController.userState == .notLoggedIn) // Should be logged out
  }

  @Test
  func updateShopkeeperWithoutEmailChangeShowsNormalSuccess() async {
    sessionController.shopkeeper = testShopkeeper

    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: testShopkeeper
    )

    viewModel.name = "Updated Name" // Name change only, no email change

    let updateTask = Task {
      viewModel.updateShopkeeper()
    }
    await updateTask.value

    #expect(messageBus.currentMessage != nil)
    #expect(messageBus.currentMessage!.level == .success)
    #expect(messageBus.currentMessage!.message == .shopkeeperUpdated)
    #expect(sessionController.userState == .loggedIn) // Should remain logged in
  }

  @Test
  func updateShopkeeperFailure() async {
    signUpRepository.error = NativeAppTemplateAPIError.requestFailed(nil, 422, "Update failed")
    sessionController.shopkeeper = testShopkeeper

    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: testShopkeeper
    )

    viewModel.name = "Updated Name"

    let updateTask = Task {
      viewModel.updateShopkeeper()
    }
    await updateTask.value

    #expect(viewModel.isUpdating == false)
    #expect(viewModel.shouldDismiss == false)
    #expect(messageBus.currentMessage != nil)
    #expect(messageBus.currentMessage!.level == .error)
    #expect(messageBus.currentMessage!.autoDismiss == false)
  }

  @Test
  func updateShopkeeperTrimsWhitespace() async {
    sessionController.shopkeeper = testShopkeeper

    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: testShopkeeper
    )

    viewModel.name = "  Updated Name  "
    viewModel.email = "  updated@example.com  "

    let updateTask = Task {
      viewModel.updateShopkeeper()
    }
    await updateTask.value

    #expect(viewModel.shouldDismiss == true)
    #expect(messageBus.currentMessage?.level == .success)
  }

  @Test
  func destroyShopkeeperSuccess() async {
    sessionController.shopkeeper = testShopkeeper
    tabViewModel.selectedTab = .scan

    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: testShopkeeper
    )

    let destroyTask = Task {
      viewModel.destroyShopkeeper()
    }
    await destroyTask.value

    #expect(viewModel.isDeleting == false)
    #expect(viewModel.shouldDismiss == true)
    #expect(tabViewModel.selectedTab == .shops)
    #expect(messageBus.currentMessage != nil)
    #expect(messageBus.currentMessage!.level == .success)
    #expect(messageBus.currentMessage!.message == .shopkeeperDeleted)
    #expect(sessionController.shopkeeper == nil)
  }

  @Test
  func destroyShopkeeperFailure() async {
    signUpRepository.error = NativeAppTemplateAPIError.requestFailed(nil, 500, "Delete failed")
    sessionController.shopkeeper = testShopkeeper

    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: testShopkeeper
    )

    let destroyTask = Task {
      viewModel.destroyShopkeeper()
    }
    await destroyTask.value

    #expect(viewModel.isDeleting == false)
    #expect(viewModel.shouldDismiss == true) // Still dismisses even on failure
    #expect(tabViewModel.selectedTab == .shops)
    #expect(messageBus.currentMessage != nil)
    #expect(messageBus.currentMessage!.level == .error)
    #expect(messageBus.currentMessage!.autoDismiss == false)
  }

  @Test
  func busyStateDuringUpdate() async {
    sessionController.shopkeeper = testShopkeeper

    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: testShopkeeper
    )

    viewModel.name = "Updated Name"

    let updateTask = Task {
      viewModel.updateShopkeeper()
    }

    // Check busy state immediately after starting
    #expect(viewModel.isBusy == viewModel.isUpdating)

    await updateTask.value

    #expect(viewModel.isBusy == false)
    #expect(viewModel.isUpdating == false)
  }

  @Test
  func busyStateDuringDeletion() async {
    sessionController.shopkeeper = testShopkeeper

    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: testShopkeeper
    )

    let destroyTask = Task {
      viewModel.destroyShopkeeper()
    }

    // Check busy state immediately after starting
    #expect(viewModel.isBusy == viewModel.isDeleting)

    await destroyTask.value

    #expect(viewModel.isBusy == false)
    #expect(viewModel.isDeleting == false)
  }

  @Test
  func dialogStateManagement() {
    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: testShopkeeper
    )

    #expect(viewModel.isShowingDeleteConfirmationDialog == false)

    viewModel.isShowingDeleteConfirmationDialog = true
    #expect(viewModel.isShowingDeleteConfirmationDialog == true)

    viewModel.isShowingDeleteConfirmationDialog = false
    #expect(viewModel.isShowingDeleteConfirmationDialog == false)
  }

  @Test("Time zone validation", arguments: [
    "Tokyo",
    "Osaka",
    "UTC",
    "America/New_York",
    "Europe/London"
  ])
  func timeZoneValidation(timeZone: String) {
    let viewModel = ShopkeeperEditViewModel(
      signUpRepository: signUpRepository,
      sessionController: sessionController,
      messageBus: messageBus,
      tabViewModel: tabViewModel,
      shopkeeper: testShopkeeper
    )

    viewModel.selectedTimeZone = timeZone
    viewModel.name = "Different Name" // Make sure data is changed

    #expect(viewModel.hasInvalidData == false) // Any time zone string should be valid
  }
}
