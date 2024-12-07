//
//  ResendConfirmationInstructionsView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/09/30.
//

import SwiftUI

struct ResendConfirmationInstructionsView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(MessageBus.self) private var messageBus
  @State var email: String = ""
  @State private var isSendingConfirmationInstructions = false
  let signUpRepository: SignUpRepository

  init(
    signUpRepository: SignUpRepository
  ) {
    self.signUpRepository = signUpRepository
  }

  private var hasInvalidData: Bool {
    if Utility.isBlank(email) {
      return true
    }
    
    if !Utility.validateEmail(email) {
      return true
    }
    
    return false
  }
}

extension ResendConfirmationInstructionsView {
  var body: some View {
    contentView
  }
}

// MARK: - private
private extension ResendConfirmationInstructionsView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      if isSendingConfirmationInstructions {
        LoadingView()
      } else {
        resendConfirmationInstructionsView
      }
    }
    
    return contentView
  }
  
  var resendConfirmationInstructionsView: some View {
    Form {
      Section {
        TextField(String.placeholderEmail, text: $email)
          .textContentType(.emailAddress)
          .autocapitalization(.none)
      } header: {
        Text(String.email)
      } footer: {
        if Utility.isBlank(email) {
          Text(String.emailIsRequired)
            .foregroundStyle(.red)
        } else if !Utility.validateEmail(email) {
          Text(String.emailIsInvalid)
            .foregroundStyle(.red)
        }
      }

      MainButtonView(title: String.buttonSendMeConfirmationInstructions, type: .primary(withArrow: false)) {
        sendMeConfirmationInstructionsTapped()
      }
      .disabled(hasInvalidData)
      .listRowBackground(Color.clear)
    }
    .navigationTitle(String.didntReceiveConfirmationInstructions)
  }
  
  private func sendMeConfirmationInstructionsTapped() {
    let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
    let theEmail = email.trimmingCharacters(in: whitespacesAndNewlines)
        
    Task { @MainActor in
      do {
        let sendConfirmation = SendConfirmation(email: theEmail)
        try await signUpRepository.sendConfirmationInstruction(sendConfirmation: sendConfirmation)
        messageBus.post(message: Message(level: .success, message: .sentConfirmationInstruction, autoDismiss: false))
        dismiss()
      } catch {
        UIApplication.dismissKeyboard()
        messageBus.post(message: Message(level: .error, message: String.sentConfirmationInstructionError, autoDismiss: false))
      }
    }
  }
}
