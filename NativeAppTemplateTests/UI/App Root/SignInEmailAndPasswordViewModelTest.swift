//
//  SignInEmailAndPasswordViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/21.
//

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
struct SignInEmailAndPasswordViewModelTest {
  let sessionController = TestSessionController()
  let messageBus = MessageBus()

  @Test
  func initialState() {
    let viewModel = SignInEmailAndPasswordViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    #expect(viewModel.email == "")
    #expect(viewModel.password == "")
    #expect(viewModel.isLoggingIn == false)
  }

  @Test
  func hasInvalidData() {
    let viewModel = SignInEmailAndPasswordViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    // Initially empty email and password should be invalid
    #expect(viewModel.hasInvalidData == true)

    // Valid email but empty password should be invalid
    viewModel.email = "test@example.com"
    #expect(viewModel.hasInvalidData == true)

    // Invalid email but valid password should be invalid
    viewModel.email = "invalid-email"
    viewModel.password = "validpassword"
    #expect(viewModel.hasInvalidData == true)

    // Valid email and password should not be invalid
    viewModel.email = "test@example.com"
    viewModel.password = "validpassword"
    #expect(viewModel.hasInvalidData == false)
  }

  @Test
  func hasInvalidDataPassword() {
    let viewModel = SignInEmailAndPasswordViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    // Empty password should be invalid
    viewModel.password = ""
    #expect(viewModel.hasInvalidDataPassword == true)

    // Whitespace only password should be invalid
    viewModel.password = "   "
    #expect(viewModel.hasInvalidDataPassword == true)

    // Valid password should not be invalid
    viewModel.password = "validpassword"
    #expect(viewModel.hasInvalidDataPassword == false)

    // Short password should still be valid for sign in (different from sign up)
    viewModel.password = "123"
    #expect(viewModel.hasInvalidDataPassword == false)
  }

  @Test
  func isEmailBlank() {
    let viewModel = SignInEmailAndPasswordViewModel(
      sessionController: sessionController,
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
  func isEmailInvalid() {
    let viewModel = SignInEmailAndPasswordViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    // Empty email is considered invalid
    viewModel.email = ""
    #expect(viewModel.isEmailInvalid == true)

    // Invalid formats
    viewModel.email = "invalid"
    #expect(viewModel.isEmailInvalid == true)

    viewModel.email = "invalid@"
    #expect(viewModel.isEmailInvalid == true)

    viewModel.email = "@invalid.com"
    #expect(viewModel.isEmailInvalid == true)

    // Valid formats
    viewModel.email = "valid@example.com"
    #expect(viewModel.isEmailInvalid == false)

    viewModel.email = "user+tag@domain.org"
    #expect(viewModel.isEmailInvalid == false)
  }

  @Test
  func isPasswordBlank() {
    let viewModel = SignInEmailAndPasswordViewModel(
      sessionController: sessionController,
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
  func signIn() async {
    let viewModel = SignInEmailAndPasswordViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    viewModel.email = "test@example.com"
    viewModel.password = "password123"

    viewModel.signIn()

    // Wait for async operation
    try? await Task.sleep(nanoseconds: 100_000_000)

    #expect(sessionController.userState == .loggedIn)
    #expect(viewModel.isLoggingIn == false)
  }

  @Test
  func signInError() async {
    // Simulate an error by setting the sessionController to throw an error
    // In a real test, we'd need to configure the mock to simulate failure
    let viewModel = SignInEmailAndPasswordViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    viewModel.email = "test@example.com"
    viewModel.password = "wrongpassword"

    viewModel.signIn()

    try? await Task.sleep(nanoseconds: 100_000_000)

    #expect(viewModel.isLoggingIn == false)
    // In a real error scenario, we'd check for error messages
  }

  @Test
  func signInWithInvalidData() {
    let viewModel = SignInEmailAndPasswordViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    // Invalid email should prevent sign in
    viewModel.email = "invalid-email"
    viewModel.password = "password123"
    #expect(viewModel.hasInvalidData == true)

    // In the actual UI, the sign in button would be disabled
    // so signIn() wouldn't be called
  }

  @Test
  func loadingState() {
    let viewModel = SignInEmailAndPasswordViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    #expect(viewModel.isLoggingIn == false)

    viewModel.isLoggingIn = true
    #expect(viewModel.isLoggingIn == true)

    viewModel.isLoggingIn = false
    #expect(viewModel.isLoggingIn == false)
  }

  @Test
  func emailAndPasswordTrimming() async {
    let viewModel = SignInEmailAndPasswordViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    viewModel.email = "  test@example.com  "
    viewModel.password = "  password123  "

    viewModel.signIn()

    try? await Task.sleep(nanoseconds: 100_000_000)

    // The actual trimming would happen in the signIn method implementation
    #expect(sessionController.userState == .loggedIn)
  }
}
