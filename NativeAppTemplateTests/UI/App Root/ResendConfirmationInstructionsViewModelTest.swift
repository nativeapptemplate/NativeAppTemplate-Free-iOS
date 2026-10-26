//
//  ResendConfirmationInstructionsViewModelTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
struct ResendConfirmationInstructionsViewModelTest {
    let messageBus = MessageBus()
    let signUpRepository = TestSignUpRepository()

    private func makeViewModel(email: String = "") -> ResendConfirmationInstructionsViewModel {
        let viewModel = ResendConfirmationInstructionsViewModel(
            signUpRepository: signUpRepository,
            messageBus: messageBus
        )
        viewModel.email = email
        return viewModel
    }

    /// hasInvalidData is true for a blank email or one String.isValidEmail rejects;
    /// isEmailInvalid only for a non-blank one (the form shows one message at a time)
    @Test(arguments: [
        ("", true, true, false),
        ("   ", true, true, false),
        ("invalid-email", true, false, true),
        ("valid@example.com", false, false, false)
    ])
    func validation(email: String, hasInvalidData: Bool, isEmailBlank: Bool, isEmailInvalid: Bool) {
        let viewModel = makeViewModel(email: email)

        #expect(viewModel.hasInvalidData == hasInvalidData)
        #expect(viewModel.isEmailBlank == isEmailBlank)
        #expect(viewModel.isEmailInvalid == isEmailInvalid)
    }

    @Test
    func sendingTrimsTheEmailAndDismissesWithASuccessMessage() async {
        let viewModel = makeViewModel(email: "  a@example.com\n")

        viewModel.sendMeConfirmationInstructionsTapped()
        await waitUntil { viewModel.shouldDismiss }

        #expect(signUpRepository.lastSendConfirmation?.email == "a@example.com")
        #expect(!viewModel.isSendingConfirmationInstructions)
        // Strings.sentConfirmationInstruction, kept on screen (autoDismiss: false)
        #expect(messageBus.currentMessage?.level == .success)
        #expect(messageBus.currentMessage?.message == Strings.sentConfirmationInstruction)
        #expect(messageBus.currentMessage?.autoDismiss == false)
    }

    /// The error shown is the API's error_message, not a fixed text
    @Test
    func failedSendStaysWithAnErrorMessage() async {
        signUpRepository.error = .requestFailed(nil, 404, "Not found")
        let viewModel = makeViewModel(email: "a@example.com")

        viewModel.sendMeConfirmationInstructionsTapped()
        await waitUntil { signUpRepository.sendConfirmationCalled && !viewModel.isSendingConfirmationInstructions }

        #expect(!viewModel.shouldDismiss)
        #expect(messageBus.currentMessage?.level == .error)
        // CodedError.formattedDescription: "[<errorCode>] <errorDescription>"
        #expect(messageBus.currentMessage?.message == "[NATIVEAPPTEMPLATE-2001] Not found")
        #expect(messageBus.currentMessage?.autoDismiss == false)
    }

    /// The API answers 429 when mail requests for one address come too often
    /// (the API's `ThrottleMailRequests`); its error_message is what the user must
    /// read, not "Unable to find user with the email."
    @Test
    func sendMeConfirmationInstructionsTappedShowsAPIMessage() async {
        signUpRepository.error = .requestFailed(nil, 429, "Too many requests. Please try again later.")
        let viewModel = makeViewModel(email: "a@example.com")

        viewModel.sendMeConfirmationInstructionsTapped()
        await waitUntil { messageBus.currentMessage != nil }

        // CodedError.formattedDescription: "[<errorCode>] <errorDescription>"
        #expect(
            messageBus.currentMessage?.message == "[NATIVEAPPTEMPLATE-2001] Too many requests. Please try again later."
        )
        #expect(messageBus.currentMessage?.autoDismiss == false)
    }
}
