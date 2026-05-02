//
//  SignInEmailAndPasswordViewModel.swift
//  NativeAppTemplate
//

import Observation
import SwiftUI

@Observable
@MainActor
final class SignInEmailAndPasswordViewModel {
    var email = ""
    var password = ""
    var isLoggingIn = false

    private let sessionController: SessionControllerProtocol
    private let messageBus: MessageBus

    init(
        sessionController: SessionControllerProtocol,
        messageBus: MessageBus
    ) {
        self.sessionController = sessionController
        self.messageBus = messageBus
    }

    var hasInvalidData: Bool {
        if email.isBlank || password.isBlank {
            return true
        }

        if !email.isValidEmail {
            return true
        }

        if hasInvalidDataPassword {
            return true
        }

        return false
    }

    var hasInvalidDataPassword: Bool {
        if password.isBlank {
            return true
        }

        return false
    }

    var isEmailBlank: Bool {
        email.isBlank
    }

    var isEmailInvalid: Bool {
        email.isBlank || !email.isValidEmail
    }

    var isPasswordBlank: Bool {
        password.isBlank
    }

    func signIn() {
        Task {
            let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
            let theEmail = email.trimmingCharacters(in: whitespacesAndNewlines)
            let thePassword = password.trimmingCharacters(in: whitespacesAndNewlines)

            do {
                isLoggingIn = true
                try await sessionController.login(email: theEmail, password: thePassword)
            } catch {
                messageBus.post(message: Message(error: error))
            }

            isLoggingIn = false
        }
    }
}
