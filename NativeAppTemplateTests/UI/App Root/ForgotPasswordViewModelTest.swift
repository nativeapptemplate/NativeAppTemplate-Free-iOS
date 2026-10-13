//
//  ForgotPasswordViewModelTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
struct ForgotPasswordViewModelTest {
    let messageBus = MessageBus()
    let signUpRepository = TestSignUpRepository()

    private func makeViewModel(email: String = "") -> ForgotPasswordViewModel {
        let viewModel = ForgotPasswordViewModel(signUpRepository: signUpRepository, messageBus: messageBus)
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

        viewModel.sendMeResetPasswordInstructionsTapped()
        await waitUntil { viewModel.shouldDismiss }

        #expect(signUpRepository.lastSendResetPassword?.email == "a@example.com")
        #expect(!viewModel.isSendingResetPasswordInstructions)
        // Strings.sentResetPasswordInstruction, kept on screen (autoDismiss: false)
        #expect(messageBus.currentMessage?.level == .success)
        #expect(messageBus.currentMessage?.message == Strings.sentResetPasswordInstruction)
        #expect(messageBus.currentMessage?.autoDismiss == false)
    }

    /// The error shown is the fixed Strings.sentResetPasswordInstructionError, not the API's message
    @Test
    func failedSendStaysWithAnErrorMessage() async {
        signUpRepository.error = .requestFailed(nil, 404, "Not found")
        let viewModel = makeViewModel(email: "a@example.com")

        viewModel.sendMeResetPasswordInstructionsTapped()
        await waitUntil { signUpRepository.sendResetPasswordCalled && !viewModel.isSendingResetPasswordInstructions }

        #expect(!viewModel.shouldDismiss)
        #expect(messageBus.currentMessage?.level == .error)
        #expect(messageBus.currentMessage?.message == Strings.sentResetPasswordInstructionError)
        #expect(messageBus.currentMessage?.autoDismiss == false)
    }
}
