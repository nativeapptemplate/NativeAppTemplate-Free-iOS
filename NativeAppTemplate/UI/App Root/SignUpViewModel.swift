//
//  SignUpViewModel.swift
//  NativeAppTemplate
//

import Observation
import SwiftUI

@Observable
@MainActor
final class SignUpViewModel {
    var name = ""
    var email = ""
    var password = ""
    var selectedTimeZone: String
    var isCreating = false
    var errorMessage = ""
    var isShowingAlert = false
    var shouldDismiss = false

    private let signUpRepository: SignUpRepositoryProtocol
    private let messageBus: MessageBus

    init(
        signUpRepository: SignUpRepositoryProtocol,
        messageBus: MessageBus
    ) {
        self.signUpRepository = signUpRepository
        self.messageBus = messageBus
        selectedTimeZone = Utility.currentTimeZone()
    }

    var hasInvalidData: Bool {
        if name.isBlank {
            return true
        }

        if hasInvalidDataEmail {
            return true
        }

        if hasInvalidDataPassword {
            return true
        }

        return false
    }

    var hasInvalidDataEmail: Bool {
        if email.isBlank {
            return true
        }

        if !email.isValidEmail {
            return true
        }

        return false
    }

    var hasInvalidDataPassword: Bool {
        if password.isBlank {
            return true
        }

        if password.count < .minimumPasswordLength {
            return true
        }

        return false
    }

    var isNameBlank: Bool {
        name.isBlank
    }

    var isEmailBlank: Bool {
        email.isBlank
    }

    var isPasswordBlank: Bool {
        password.isBlank
    }

    func createShopkeeper() {
        Task {
            let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
            let theName = name.trimmingCharacters(in: whitespacesAndNewlines)
            let theEmail = email.trimmingCharacters(in: whitespacesAndNewlines)
            let thePassword = password.trimmingCharacters(in: whitespacesAndNewlines)

            isCreating = true

            do {
                let signUp = SignUp(
                    name: theName,
                    email: theEmail,
                    timeZone: selectedTimeZone,
                    password: thePassword
                )
                _ = try await signUpRepository.signUp(signUp: signUp)

                messageBus.post(message: Message(
                    level: .success,
                    message: Strings.signedUpButUnconfirmed,
                    autoDismiss: false
                ))
                shouldDismiss = true
            } catch let NativeAppTemplateAPIError.requestFailed(_, _, message) {
                errorMessage = message ?? "UNKNOWN"
                isShowingAlert = true
            } catch {
                errorMessage = error.codedDescription
                isShowingAlert = true
            }

            isCreating = false
        }
    }
}
