//
//  PasswordEditViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/20.
//

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
struct PasswordEditViewModelTest {
  let accountPasswordRepository = TestAccountPasswordRepository(
    accountPasswordService: AccountPasswordService()
  )
  let messageBus = MessageBus()

  @Test
  func initializesCorrectly() {
    let viewModel = PasswordEditViewModel(
      accountPasswordRepository: accountPasswordRepository,
      messageBus: messageBus
    )

    #expect(viewModel.currentPassword == "")
    #expect(viewModel.password == "")
    #expect(viewModel.passwordConfirmation == "")
    #expect(viewModel.isUpdating == false)
    #expect(viewModel.shouldDismiss == false)
    #expect(viewModel.isBusy == false)
  }

  @Test
  func busyStateReflectsUpdatingState() {
    let viewModel = PasswordEditViewModel(
      accountPasswordRepository: accountPasswordRepository,
      messageBus: messageBus
    )

    #expect(viewModel.isBusy == false)

    viewModel.isUpdating = true
    #expect(viewModel.isBusy == true)

    viewModel.isUpdating = false
    #expect(viewModel.isBusy == false)
  }

  @Test
  func minimumPasswordLengthReturnsCorrectValue() {
    let viewModel = PasswordEditViewModel(
      accountPasswordRepository: accountPasswordRepository,
      messageBus: messageBus
    )

    #expect(viewModel.minimumPasswordLength == .minimumPasswordLength)
  }

  @Test("Password validation", arguments: [
    ("", true), // blank password
    ("a", true), // too short (minimum is 8)
    ("ab", true), // too short (minimum is 8)
    ("abc", true), // too short (minimum is 8)
    ("abcd", true), // too short (minimum is 8)
    ("abcde", true), // too short (minimum is 8)
    ("abcdef", true), // too short (minimum is 8)
    ("abcdefg", true), // too short (minimum is 8)
    ("abcdefgh", false), // meets minimum length of 8
    ("verylongpassword", false) // definitely meets minimum
  ])
  func passwordValidation(password: String, shouldBeInvalid: Bool) {
    let viewModel = PasswordEditViewModel(
      accountPasswordRepository: accountPasswordRepository,
      messageBus: messageBus
    )

    viewModel.password = password

    #expect(viewModel.hasInvalidDataPassword == shouldBeInvalid)
  }

  @Test("Form validation - blank fields", arguments: [
    ("", "password", "password", true), // blank current password
    ("current", "", "password", true), // blank password
    ("current", "password", "", true), // blank confirmation
    ("current", "password", "password", false) // all filled
  ])
  func formValidationBlankFields(
    currentPassword: String,
    password: String,
    passwordConfirmation: String,
    shouldBeInvalid: Bool
  ) {
    let viewModel = PasswordEditViewModel(
      accountPasswordRepository: accountPasswordRepository,
      messageBus: messageBus
    )

    viewModel.currentPassword = currentPassword
    viewModel.password = password
    viewModel.passwordConfirmation = passwordConfirmation

    #expect(viewModel.hasInvalidData == shouldBeInvalid)
  }

  @Test
  func formValidationWithInvalidPassword() {
    let viewModel = PasswordEditViewModel(
      accountPasswordRepository: accountPasswordRepository,
      messageBus: messageBus
    )

    // Set valid current password and confirmation, but invalid password
    viewModel.currentPassword = "currentpassword"
    viewModel.password = "a" // too short
    viewModel.passwordConfirmation = "a"

    #expect(viewModel.hasInvalidData == true)
    #expect(viewModel.hasInvalidDataPassword == true)
  }

  @Test
  func updatePasswordSuccess() async {
    let viewModel = PasswordEditViewModel(
      accountPasswordRepository: accountPasswordRepository,
      messageBus: messageBus
    )

    viewModel.currentPassword = "currentpassword"
    viewModel.password = "newpassword"
    viewModel.passwordConfirmation = "newpassword"

    let updateTask = Task {
      viewModel.updatePassword()
    }
    await updateTask.value

    #expect(viewModel.isUpdating == false)
    #expect(viewModel.shouldDismiss == true)
    #expect(messageBus.currentMessage != nil)
    #expect(messageBus.currentMessage!.level == .success)
    #expect(messageBus.currentMessage!.message == .passwordUpdated)
  }

  @Test
  func updatePasswordFailure() async {
    accountPasswordRepository.error = NativeAppTemplateAPIError.requestFailed(nil, 422, "Current password is incorrect")

    let viewModel = PasswordEditViewModel(
      accountPasswordRepository: accountPasswordRepository,
      messageBus: messageBus
    )

    viewModel.currentPassword = "wrongpassword"
    viewModel.password = "newpassword"
    viewModel.passwordConfirmation = "newpassword"

    let updateTask = Task {
      viewModel.updatePassword()
    }
    await updateTask.value

    #expect(viewModel.isUpdating == false)
    #expect(viewModel.shouldDismiss == false)
    #expect(messageBus.currentMessage != nil)
    #expect(messageBus.currentMessage!.level == .error)
    #expect(messageBus.currentMessage!.autoDismiss == false)
  }

  @Test
  func updatePasswordTrimsWhitespace() async {
    let viewModel = PasswordEditViewModel(
      accountPasswordRepository: accountPasswordRepository,
      messageBus: messageBus
    )

    viewModel.currentPassword = "  currentpassword  "
    viewModel.password = "  newpassword  "
    viewModel.passwordConfirmation = "  newpassword  "

    let updateTask = Task {
      viewModel.updatePassword()
    }
    await updateTask.value

    #expect(viewModel.shouldDismiss == true)
    #expect(messageBus.currentMessage?.level == .success)
  }

  @Test
  func busyStateDuringUpdate() async {
    let viewModel = PasswordEditViewModel(
      accountPasswordRepository: accountPasswordRepository,
      messageBus: messageBus
    )

    viewModel.currentPassword = "currentpassword"
    viewModel.password = "newpassword"
    viewModel.passwordConfirmation = "newpassword"

    let updateTask = Task {
      viewModel.updatePassword()
    }

    // Check busy state immediately after starting
    #expect(viewModel.isBusy == viewModel.isUpdating)

    await updateTask.value

    #expect(viewModel.isBusy == false)
    #expect(viewModel.isUpdating == false)
  }

  @Test
  func passwordLengthValidationAtMinimumBoundary() {
    let viewModel = PasswordEditViewModel(
      accountPasswordRepository: accountPasswordRepository,
      messageBus: messageBus
    )

    // Test password just under the minimum (7 characters)
    viewModel.password = String(repeating: "a", count: 7)
    #expect(viewModel.hasInvalidDataPassword == true)

    // Test password at the minimum (8 characters)
    viewModel.password = String(repeating: "a", count: 8)
    #expect(viewModel.hasInvalidDataPassword == false)

    // Test password over the minimum (9 characters)
    viewModel.password = String(repeating: "a", count: 9)
    #expect(viewModel.hasInvalidDataPassword == false)

    // Verify the minimum matches the constant
    #expect(viewModel.minimumPasswordLength == 8)
  }
}
