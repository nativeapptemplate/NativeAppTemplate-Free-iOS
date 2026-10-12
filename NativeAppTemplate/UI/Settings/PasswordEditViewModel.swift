//
//  PasswordEditViewModel.swift
//  NativeAppTemplate
//

import Observation
import SwiftUI

@Observable
@MainActor
final class PasswordEditViewModel {
    var currentPassword = ""
    var password = ""
    var passwordConfirmation = ""
    var isUpdating = false
    var shouldDismiss = false

    private let accountPasswordRepository: AccountPasswordRepositoryProtocol
    private let messageBus: MessageBus

    init(
        accountPasswordRepository: AccountPasswordRepositoryProtocol,
        messageBus: MessageBus
    ) {
        self.accountPasswordRepository = accountPasswordRepository
        self.messageBus = messageBus
    }

    var isBusy: Bool {
        isUpdating
    }

    var hasInvalidData: Bool {
        if currentPassword.isBlank ||
            password.isBlank ||
            passwordConfirmation.isBlank {
            return true
        }

        if hasInvalidDataPassword {
            return true
        }

        if hasPasswordConfirmationMismatch {
            return true
        }

        return false
    }

    /// True once a confirmation is entered that does not match the new password
    var hasPasswordConfirmationMismatch: Bool {
        !passwordConfirmation.isEmpty && passwordConfirmation != password
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

    var minimumPasswordLength: Int {
        .minimumPasswordLength
    }

    func updatePassword() {
        let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
        let theCurrentPassword = currentPassword.trimmingCharacters(in: whitespacesAndNewlines)
        let thePassword = password.trimmingCharacters(in: whitespacesAndNewlines)
        let thePasswordConfirmation = passwordConfirmation.trimmingCharacters(in: whitespacesAndNewlines)

        Task {
            isUpdating = true

            await saveThenDismiss(
                messageBus: messageBus,
                successMessage: Strings.passwordUpdated,
                dismiss: { shouldDismiss = true },
                save: {
                    let updatePassword = UpdatePassword(
                        currentPassword: theCurrentPassword,
                        password: thePassword,
                        passwordConfirmation: thePasswordConfirmation
                    )

                    try await accountPasswordRepository.update(updatePassword: updatePassword)
                }
            )

            isUpdating = false
        }
    }
}
