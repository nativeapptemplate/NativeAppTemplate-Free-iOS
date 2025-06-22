//
//  ForgotPasswordView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/03/02.
//

import SwiftUI

struct ForgotPasswordView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(MessageBus.self) private var messageBus
  @State var email: String = ""
  @State private var isSendingResetPasswordInstructions = false
  let signUpRepository: SignUpRepositoryProtocol

  init(
    signUpRepository: SignUpRepositoryProtocol
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

extension ForgotPasswordView {
  var body: some View {
    contentView
  }
}

// MARK: - private
private extension ForgotPasswordView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      if isSendingResetPasswordInstructions {
        LoadingView()
      } else {
        forgotPasswordView
      }
    }
    
    return contentView
  }
  
  var forgotPasswordView: some View {
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
      
      MainButtonView(title: String.buttonSendMeResetPasswordInstructions, type: .primary(withArrow: false)) {
        sendMeResetPasswordInstructionsTapped()
      }
      .disabled(hasInvalidData)
      .listRowBackground(Color.clear)
    }
    .navigationTitle(String.forgotYourPassword)
  }
  
  private func sendMeResetPasswordInstructionsTapped() {
    let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
    let theEmail = email.trimmingCharacters(in: whitespacesAndNewlines)
        
    Task { @MainActor in
      do {
        let sendResetPassword = SendResetPassword(email: theEmail)
        try await signUpRepository.sendResetPasswordInstruction(sendResetPassword: sendResetPassword)
        messageBus.post(message: Message(level: .success, message: .sentResetPasswordInstruction, autoDismiss: false))
        dismiss()
      } catch {
        UIApplication.dismissKeyboard()
        messageBus.post(message: Message(level: .error, message: String.sentResetPasswordInstructionError, autoDismiss: false))
      }
    }
  }
}
