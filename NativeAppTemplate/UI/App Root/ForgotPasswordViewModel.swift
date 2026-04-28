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
        if Utility.isBlank(email) {
            return true
        }

        if !Utility.validateEmail(email) {
            return true
        }

        return false
    }

    var isEmailBlank: Bool {
        Utility.isBlank(email)
    }

    var isEmailInvalid: Bool {
        !Utility.isBlank(email) && !Utility.validateEmail(email)
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
