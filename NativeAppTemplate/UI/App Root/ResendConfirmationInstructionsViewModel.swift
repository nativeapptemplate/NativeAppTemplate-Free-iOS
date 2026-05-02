//
//  ResendConfirmationInstructionsViewModel.swift
//  NativeAppTemplate
//

import Observation
import SwiftUI

@Observable
@MainActor
final class ResendConfirmationInstructionsViewModel {
    var email = ""
    var shouldDismiss = false
    var isSendingConfirmationInstructions = false

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

    func sendMeConfirmationInstructionsTapped() {
        let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
        let theEmail = email.trimmingCharacters(in: whitespacesAndNewlines)

        Task { @MainActor in
            isSendingConfirmationInstructions = true

            do {
                let sendConfirmation = SendConfirmation(email: theEmail)
                try await signUpRepository.sendConfirmationInstruction(sendConfirmation: sendConfirmation)
                messageBus.post(message: Message(
                    level: .success,
                    message: Strings.sentConfirmationInstruction,
                    autoDismiss: false
                ))
                shouldDismiss = true
            } catch {
                UIApplication.dismissKeyboard()
                messageBus.post(message: Message(
                    level: .error,
                    message: Strings.sentConfirmationInstructionError,
                    autoDismiss: false
                ))
            }

            isSendingConfirmationInstructions = false
        }
    }
}
