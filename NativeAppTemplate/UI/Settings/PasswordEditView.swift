//
//  PasswordEditView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/25.
//

import SwiftUI

struct PasswordEditView: View {
  @Environment(MessageBus.self) private var messageBus
  @Environment(\.dismiss) private var dismiss
  @State private var isUpdating = false
  @State private var currentPassword: String = ""
  @State private var password: String = ""
  @State private var passwordConfirmation: String = ""
  private var accountPasswordRepository: AccountPasswordRepositoryProtocol

  init(
    accountPasswordRepository: AccountPasswordRepositoryProtocol
  ) {
    self.accountPasswordRepository = accountPasswordRepository
  }

  private var hasInvalidData: Bool {
    if Utility.isBlank(currentPassword) ||
        Utility.isBlank(password) ||
        Utility.isBlank(passwordConfirmation) {
      return true
    }
    
    if hasInvalidDataPassword {
      return true
    }
    
    return false
  }

  private var hasInvalidDataPassword: Bool {
    if Utility.isBlank(password) {
      return true
    }

    if password.count < .minimumPasswordLength {
      return true
    }

    return false
  }

  var body: some View {
    contentView
  }
}

// MARK: - private
private extension PasswordEditView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      if isUpdating {
        LoadingView()
      } else {
        passwordEditView
      }
    }
    
    return contentView
  }
  
  var passwordEditView: some View {
    Form {
      Section {
        SecureField(String.currentPassword, text: $currentPassword)
          .textContentType(.password)
          .autocapitalization(.none)
          .autocorrectionDisabled(true)
      } header: {
        Text(String.currentPassword)
      } footer: {
        VStack(alignment: .leading) {
          Text(String.weNeedYourCurrentPassword)
            .font(.uiFootnote)
          Text(String.currentPasswordIsRequired)
            .foregroundStyle(Utility.isBlank(currentPassword) ? .red : .clear)
            .font(.uiFootnote)
        }
      }
      Section {
        SecureField(String.newPassword, text: $password)
          .textContentType(.password)
          .autocapitalization(.none)
          .autocorrectionDisabled(true)
      } header: {
        Text(String.newPassword)
      } footer: {
        VStack(alignment: .leading) {
          Text("\(Int.minimumPasswordLength) characters minimum.")
            .font(.uiFootnote)
          
          if Utility.isBlank(password) {
            Text(String.newPasswordIsRequired)
              .foregroundStyle(.red)
              .font(.uiFootnote)
          } else if hasInvalidDataPassword {
            Text(String.passwordIsInvalid)
              .foregroundStyle(.red)
              .font(.uiFootnote)
          }
        }
      }
      Section {
        SecureField(String.confirmNewPassword, text: $passwordConfirmation)
          .textContentType(.password)
          .autocapitalization(.none)
          .autocorrectionDisabled(true)
      } header: {
        Text(String.confirmNewPassword)
      } footer: {
        Text(String.confirmNewPasswordIsRequired)
          .font(.uiFootnote)
          .foregroundStyle(Utility.isBlank(passwordConfirmation) ? .red : .clear)
      }
    }
   .navigationTitle(String.updatePassword)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          updatePassword()
        } label: {
          Text(String.save)
        }
        .disabled(hasInvalidData)
      }
    }
  }
  
  func updatePassword() {
    let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
    let theCurrentPassword = currentPassword.trimmingCharacters(in: whitespacesAndNewlines)
    let thePassword = password.trimmingCharacters(in: whitespacesAndNewlines)
    let thePasswordConfirmation = passwordConfirmation.trimmingCharacters(in: whitespacesAndNewlines)

    Task { @MainActor in
      isUpdating = true

      do {
        let updatePassword = UpdatePassword(
          currentPassword: theCurrentPassword,
          password: thePassword,
          passwordConfirmation: thePasswordConfirmation
        )
        
        try await accountPasswordRepository.update(updatePassword: updatePassword)
        messageBus.post(message: Message(level: .success, message: .passwordUpdated))
        dismiss()
      } catch {
        messageBus.post(message: Message(level: .error, message: error.localizedDescription, autoDismiss: false))
      }
      
      isUpdating = false
    }
  }
}
