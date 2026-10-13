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

    /// The error shown is the fixed Strings.sentConfirmationInstructionError, not the API's message
    @Test
    func failedSendStaysWithAnErrorMessage() async {
        signUpRepository.error = .requestFailed(nil, 404, "Not found")
        let viewModel = makeViewModel(email: "a@example.com")

        viewModel.sendMeConfirmationInstructionsTapped()
        await waitUntil { signUpRepository.sendConfirmationCalled && !viewModel.isSendingConfirmationInstructions }

        #expect(!viewModel.shouldDismiss)
        #expect(messageBus.currentMessage?.level == .error)
        #expect(messageBus.currentMessage?.message == Strings.sentConfirmationInstructionError)
        #expect(messageBus.currentMessage?.autoDismiss == false)
    }
}
