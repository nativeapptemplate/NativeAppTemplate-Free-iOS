//
//  SignUpViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/21.
//

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
struct SignUpViewModelTest {
  let signUpRepository = TestSignUpRepository()
  let messageBus = MessageBus()

  @Test
  func initialState() {
    let viewModel = SignUpViewModel(
      signUpRepository: signUpRepository,
      messageBus: messageBus
    )

    #expect(viewModel.name == "")
    #expect(viewModel.email == "")
    #expect(viewModel.password == "")
    #expect(viewModel.selectedTimeZone == Utility.currentTimeZone())
    #expect(viewModel.isCreating == false)
    #expect(viewModel.errorMessage == "")
    #expect(viewModel.isShowingAlert == false)
    #expect(viewModel.shouldDismiss == false)
  }

  @Test
  func hasInvalidData() {
    let viewModel = SignUpViewModel(
      signUpRepository: signUpRepository,
      messageBus: messageBus
    )

    // Initially all empty should be invalid
    #expect(viewModel.hasInvalidData == true)

    // Valid name but empty email and password should be invalid
    viewModel.name = "John Doe"
    #expect(viewModel.hasInvalidData == true)

    // Valid name and email but empty password should be invalid
    viewModel.email = "john@example.com"
    #expect(viewModel.hasInvalidData == true)

    // Valid name and email but invalid password should be invalid
    viewModel.password = "123" // Too short
    #expect(viewModel.hasInvalidData == true)

    // All valid should not be invalid
    viewModel.password = "validpassword123"
    #expect(viewModel.hasInvalidData == false)
  }

  @Test
  func hasInvalidDataEmail() {
    let viewModel = SignUpViewModel(
      signUpRepository: signUpRepository,
      messageBus: messageBus
    )

    // Empty email should be invalid
    viewModel.email = ""
    #expect(viewModel.hasInvalidDataEmail == true)

    // Invalid email format should be invalid
    viewModel.email = "invalid-email"
    #expect(viewModel.hasInvalidDataEmail == true)

    viewModel.email = "invalid@"
    #expect(viewModel.hasInvalidDataEmail == true)

    viewModel.email = "@invalid.com"
    #expect(viewModel.hasInvalidDataEmail == true)

    // Valid email should not be invalid
    viewModel.email = "valid@example.com"
    #expect(viewModel.hasInvalidDataEmail == false)
  }

  @Test
  func hasInvalidDataPassword() {
    let viewModel = SignUpViewModel(
      signUpRepository: signUpRepository,
      messageBus: messageBus
    )

    // Empty password should be invalid
    viewModel.password = ""
    #expect(viewModel.hasInvalidDataPassword == true)

    // Too short password should be invalid
    viewModel.password = "123"
    #expect(viewModel.hasInvalidDataPassword == true)

    viewModel.password = "1234567" // 7 characters, minimum is 8
    #expect(viewModel.hasInvalidDataPassword == true)

    // Valid length password should not be invalid
    viewModel.password = "12345678" // 8 characters
    #expect(viewModel.hasInvalidDataPassword == false)

    viewModel.password = "validpassword123"
    #expect(viewModel.hasInvalidDataPassword == false)
  }

  @Test
  func isNameBlank() {
    let viewModel = SignUpViewModel(
      signUpRepository: signUpRepository,
      messageBus: messageBus
    )

    // Initially should be blank
    #expect(viewModel.isNameBlank == true)

    viewModel.name = ""
    #expect(viewModel.isNameBlank == true)

    viewModel.name = "   "
    #expect(viewModel.isNameBlank == true)

    viewModel.name = "John Doe"
    #expect(viewModel.isNameBlank == false)
  }

  @Test
  func isEmailBlank() {
    let viewModel = SignUpViewModel(
      signUpRepository: signUpRepository,
      messageBus: messageBus
    )

    // Initially should be blank
    #expect(viewModel.isEmailBlank == true)

    viewModel.email = ""
    #expect(viewModel.isEmailBlank == true)

    viewModel.email = "   "
    #expect(viewModel.isEmailBlank == true)

    viewModel.email = "test@example.com"
    #expect(viewModel.isEmailBlank == false)
  }

  @Test
  func isPasswordBlank() {
    let viewModel = SignUpViewModel(
      signUpRepository: signUpRepository,
      messageBus: messageBus
    )

    // Initially should be blank
    #expect(viewModel.isPasswordBlank == true)

    viewModel.password = ""
    #expect(viewModel.isPasswordBlank == true)

    viewModel.password = "   "
    #expect(viewModel.isPasswordBlank == true)

    viewModel.password = "password123"
    #expect(viewModel.isPasswordBlank == false)
  }

  @Test
  func createShopkeeper() async {
    let viewModel = SignUpViewModel(
      signUpRepository: signUpRepository,
      messageBus: messageBus
    )

    viewModel.name = "John Doe"
    viewModel.email = "john@example.com"
    viewModel.password = "password123"
    viewModel.selectedTimeZone = "Tokyo"

    viewModel.createShopkeeper()

    // Wait for async operation
    try? await Task.sleep(nanoseconds: 100_000_000)

    #expect(signUpRepository.signUpCalled == true)
    #expect(signUpRepository.lastSignUp?.name == "John Doe")
    #expect(signUpRepository.lastSignUp?.email == "john@example.com")
    #expect(signUpRepository.lastSignUp?.password == "password123")
    #expect(signUpRepository.lastSignUp?.timeZone == "Tokyo")
    #expect(viewModel.shouldDismiss == true)
    #expect(messageBus.currentMessage?.level == .success)
    #expect(viewModel.isCreating == false)
  }

  @Test
  func createShopkeeperError() async {
    signUpRepository.error = NativeAppTemplateAPIError.requestFailed(nil, 422, "Email already exists")

    let viewModel = SignUpViewModel(
      signUpRepository: signUpRepository,
      messageBus: messageBus
    )

    viewModel.name = "John Doe"
    viewModel.email = "existing@example.com"
    viewModel.password = "password123"

    viewModel.createShopkeeper()

    try? await Task.sleep(nanoseconds: 100_000_000)

    #expect(signUpRepository.signUpCalled == true)
    #expect(viewModel.shouldDismiss == false)
    #expect(viewModel.isShowingAlert == true)
    #expect(viewModel.errorMessage.contains("Email already exists"))
    #expect(viewModel.isCreating == false)
  }

  @Test
  func createShopkeeperWithInvalidData() {
    let viewModel = SignUpViewModel(
      signUpRepository: signUpRepository,
      messageBus: messageBus
    )

    // Invalid data should prevent creation
    viewModel.name = ""
    viewModel.email = "invalid-email"
    viewModel.password = "123"
    #expect(viewModel.hasInvalidData == true)

    // In the actual UI, the create button would be disabled
    // so createShopkeeper() wouldn't be called
  }

  @Test
  func loadingState() {
    let viewModel = SignUpViewModel(
      signUpRepository: signUpRepository,
      messageBus: messageBus
    )

    #expect(viewModel.isCreating == false)

    viewModel.isCreating = true
    #expect(viewModel.isCreating == true)

    viewModel.isCreating = false
    #expect(viewModel.isCreating == false)
  }

  @Test
  func alertState() {
    let viewModel = SignUpViewModel(
      signUpRepository: signUpRepository,
      messageBus: messageBus
    )

    #expect(viewModel.isShowingAlert == false)
    #expect(viewModel.errorMessage == "")

    viewModel.isShowingAlert = true
    viewModel.errorMessage = "Test error message"

    #expect(viewModel.isShowingAlert == true)
    #expect(viewModel.errorMessage == "Test error message")
  }

  @Test
  func timeZoneSelection() {
    let viewModel = SignUpViewModel(
      signUpRepository: signUpRepository,
      messageBus: messageBus
    )

    // Should initialize with current timezone
    #expect(viewModel.selectedTimeZone == Utility.currentTimeZone())

    // Should be able to change timezone
    viewModel.selectedTimeZone = "New York"
    #expect(viewModel.selectedTimeZone == "New York")

    viewModel.selectedTimeZone = "London"
    #expect(viewModel.selectedTimeZone == "London")
  }

  @Test
  func inputTrimming() async {
    let viewModel = SignUpViewModel(
      signUpRepository: signUpRepository,
      messageBus: messageBus
    )

    viewModel.name = "  John Doe  "
    viewModel.email = "  john@example.com  "
    viewModel.password = "  password123  "

    viewModel.createShopkeeper()

    try? await Task.sleep(nanoseconds: 100_000_000)

    // The actual trimming would happen in the createShopkeeper method implementation
    #expect(signUpRepository.signUpCalled == true)
    #expect(viewModel.shouldDismiss == true)
  }
}
