//
//  ForgotPasswordViewModel.swift
//  NativeAppTemplate
//

import Observation
import SwiftUI

@Observable
@MainActor
final class ForgotPasswordViewModel {
    var email = ""
    var shouldDismiss = false
    var isSendingResetPasswordInstructions = false

    private let signUpRepository: SignUpRepositoryProtocol
    private let messageBus: MessageBus

    init(
        signUpRepository: SignUpRepositoryProtocol,
        messageBus: MessageBus
    ) {
        self.signUpRepository = signUpRepository
        self.messageBus = messageBus
    }

    var hasInvalidData: Bool {
        if email.isBlank {
            return true
        }

        if !email.isValidEmail {
            return true
        }

        return false
    }

    var isEmailBlank: Bool {
        email.isBlank
    }

    var isEmailInvalid: Bool {
        !email.isBlank && !email.isValidEmail
    }

    func sendMeResetPasswordInstructionsTapped() {
        let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
        let theEmail = email.trimmingCharacters(in: whitespacesAndNewlines)

        Task { @MainActor in
            isSendingResetPasswordInstructions = true

            do {
                let sendResetPassword = SendResetPassword(email: theEmail)
                try await signUpRepository.sendResetPasswordInstruction(sendResetPassword: sendResetPassword)
                messageBus.post(message: Message(
                    level: .success,
                    message: Strings.sentResetPasswordInstruction,
                    autoDismiss: false
                ))
                shouldDismiss = true
            } catch {
                UIApplication.dismissKeyboard()
                messageBus.post(message: Message(
                    level: .error,
                    message: Strings.sentResetPasswordInstructionError,
                    autoDismiss: false
                ))
            }

            isSendingResetPasswordInstructions = false
        }
    }
}
