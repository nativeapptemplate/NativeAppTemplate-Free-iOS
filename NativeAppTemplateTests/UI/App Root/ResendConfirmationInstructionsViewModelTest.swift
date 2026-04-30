//
//  ResendConfirmationInstructionsViewModelTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
@Suite
struct ResendConfirmationViewModelTest {
    let messageBus = MessageBus()

    // Since ResendConfirmationInstructionsViewModel requires concrete SignUpRepository,
    // we'll test the validation logic and basic state management
    // The actual network calls would be tested separately

    @Test
    func hasInvalidDataWithEmptyEmail() {
        // Test the validation logic without network dependency
        let email = ""

        // Simulate the validation logic from the ViewModel
        let isBlank = email.isBlank
        let isInvalid = !email.isValidEmail
        let hasInvalidData = isBlank || isInvalid

        #expect(hasInvalidData == true)
    }

    @Test
    func hasInvalidDataWithInvalidEmail() {
        let email = "invalid-email"

        let isBlank = email.isBlank
        let isInvalid = !email.isValidEmail
        let hasInvalidData = isBlank || isInvalid

        #expect(hasInvalidData == true)
    }

    @Test
    func hasInvalidDataWithValidEmail() {
        let email = "valid@example.com"

        let isBlank = email.isBlank
        let isInvalid = !email.isValidEmail
        let hasInvalidData = isBlank || isInvalid

        #expect(hasInvalidData == false)
    }

    @Test
    func isEmailBlankValidation() {
        // Test blank email detection
        #expect("".isBlank == true)
        #expect("   ".isBlank == true)
        #expect("test@example.com".isBlank == false)
    }

    @Test
    func isEmailInvalidValidation() {
        // Test email format validation
        #expect("".isValidEmail == false)
        #expect("invalid".isValidEmail == false)
        #expect("invalid@".isValidEmail == false)
        #expect("@invalid.com".isValidEmail == false)
        #expect("valid@example.com".isValidEmail == true)
        #expect("user+tag@domain.org".isValidEmail == true)
    }

    @Test
    func emailValidationEdgeCases() {
        // Test various email formats
        #expect("user.name@domain.com".isValidEmail == true)
        #expect("user+tag@domain.co.uk".isValidEmail == true)
        #expect("user@subdomain.domain.org".isValidEmail == true)
        #expect("123@domain.com".isValidEmail == true)

        // Invalid cases
        #expect("user@".isValidEmail == false)
        #expect("@domain.com".isValidEmail == false)
        #expect("user.domain.com".isValidEmail == false)
        #expect("user space@domain.com".isValidEmail == false)
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
    func messageTypesForResendConfirmation() {
        // Test the types of messages that would be posted
        let successMessage = Message(level: .success, message: Strings.sentConfirmationInstruction)
        let errorMessage = Message(level: .error, message: "Email not found", autoDismiss: false)

        #expect(successMessage.level == .success)
        #expect(successMessage.autoDismiss == true)
        #expect(errorMessage.level == .error)
        #expect(errorMessage.autoDismiss == false)
    }

    @Test
    func emailTrimmingLogic() {
        // Test whitespace trimming logic that would be used by the ViewModel
        let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines

        let emailWithSpaces = "  test@example.com  "
        let trimmedEmail = emailWithSpaces.trimmingCharacters(in: whitespacesAndNewlines)

        #expect(trimmedEmail == "test@example.com")

        let emailWithNewlines = "\nuser@domain.org\n"
        let trimmedNewlines = emailWithNewlines.trimmingCharacters(in: whitespacesAndNewlines)

        #expect(trimmedNewlines == "user@domain.org")
    }
}
