//
//  ResendConfirmationInstructionsViewModel.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/16.
//

import SwiftUI
import Observation

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

  func sendMeConfirmationInstructionsTapped() {
    let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
    let theEmail = email.trimmingCharacters(in: whitespacesAndNewlines)

    Task { @MainActor in
      isSendingConfirmationInstructions = true

      do {
        let sendConfirmation = SendConfirmation(email: theEmail)
        try await signUpRepository.sendConfirmationInstruction(sendConfirmation: sendConfirmation)
        messageBus.post(message: Message(level: .success, message: .sentConfirmationInstruction, autoDismiss: false))
        shouldDismiss = true
      } catch {
        UIApplication.dismissKeyboard()
        messageBus.post(message: Message(level: .error, message: String.sentConfirmationInstructionError, autoDismiss: false))
      }

      isSendingConfirmationInstructions = false
    }
  }
}
