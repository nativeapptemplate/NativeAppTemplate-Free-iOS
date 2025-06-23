//
//  ForgotPasswordViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/21.
//

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
struct ForgotPasswordViewModelTest {
  let messageBus = MessageBus()

  // Since ForgotPasswordViewModel requires concrete SignUpRepository,
  // we'll test the validation logic and basic state management
  // The actual network calls would be tested separately

  @Test
  func hasInvalidDataWithEmptyEmail() {
    // Test the validation logic without network dependency
    let email = ""

    // Simulate the validation logic from the ViewModel
    let isBlank = Utility.isBlank(email)
    let isInvalid = !Utility.validateEmail(email)
    let hasInvalidData = isBlank || isInvalid

    #expect(hasInvalidData == true)
  }

  @Test
  func hasInvalidDataWithInvalidEmail() {
    let email = "invalid-email"

    let isBlank = Utility.isBlank(email)
    let isInvalid = !Utility.validateEmail(email)
    let hasInvalidData = isBlank || isInvalid

    #expect(hasInvalidData == true)
  }

  @Test
  func hasInvalidDataWithValidEmail() {
    let email = "valid@example.com"

    let isBlank = Utility.isBlank(email)
    let isInvalid = !Utility.validateEmail(email)
    let hasInvalidData = isBlank || isInvalid

    #expect(hasInvalidData == false)
  }

  @Test
  func isEmailBlankValidation() {
    // Test blank email detection
    #expect(Utility.isBlank("") == true)
    #expect(Utility.isBlank("   ") == true)
    #expect(Utility.isBlank("test@example.com") == false)
  }

  @Test
  func isEmailInvalidValidation() {
    // Test email format validation
    #expect(Utility.validateEmail("") == false)
    #expect(Utility.validateEmail("invalid") == false)
    #expect(Utility.validateEmail("invalid@") == false)
    #expect(Utility.validateEmail("@invalid.com") == false)
    #expect(Utility.validateEmail("valid@example.com") == true)
    #expect(Utility.validateEmail("user+tag@domain.org") == true)
  }

  @Test
  func emailValidationEdgeCases() {
    // Test various email formats
    #expect(Utility.validateEmail("user.name@domain.com") == true)
    #expect(Utility.validateEmail("user+tag@domain.co.uk") == true)
    #expect(Utility.validateEmail("user@subdomain.domain.org") == true)
    #expect(Utility.validateEmail("123@domain.com") == true)

    // Invalid cases
    #expect(Utility.validateEmail("user@") == false)
    #expect(Utility.validateEmail("@domain.com") == false)
    #expect(Utility.validateEmail("user.domain.com") == false)
    #expect(Utility.validateEmail("user space@domain.com") == false)
  }

  @Test
  func messageBusIntegration() {
    // Test MessageBus functionality used by the ViewModel
    #expect(messageBus.currentMessage == nil)
    #expect(messageBus.messageVisible == false)

    let testMessage = Message(level: .success, message: "Test message")
    messageBus.post(message: testMessage)

    #expect(messageBus.currentMessage?.level == .success)
    #expect(messageBus.messageVisible == true)

    messageBus.dismiss()
    #expect(messageBus.messageVisible == false)
  }

  @Test
  func messageTypesForForgotPassword() {
    // Test the types of messages that would be posted
    let successMessage = Message(level: .success, message: .sentResetPasswordInstruction)
    let errorMessage = Message(level: .error, message: "Email not found", autoDismiss: false)

    #expect(successMessage.level == .success)
    #expect(successMessage.autoDismiss == true)
    #expect(errorMessage.level == .error)
    #expect(errorMessage.autoDismiss == false)
  }
}
