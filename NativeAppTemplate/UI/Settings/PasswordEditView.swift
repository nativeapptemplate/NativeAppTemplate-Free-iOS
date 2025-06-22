//
//  PasswordEditView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/25.
//

import SwiftUI

struct PasswordEditView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var viewModel: PasswordEditViewModel

  init(viewModel: PasswordEditViewModel) {
    self._viewModel = State(wrappedValue: viewModel)
  }

  var body: some View {
    contentView
      .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
        if shouldDismiss {
          dismiss()
        }
      }
  }
}

// MARK: - private
private extension PasswordEditView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      if viewModel.isBusy {
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
        SecureField(String.currentPassword, text: $viewModel.currentPassword)
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
            .foregroundStyle(Utility.isBlank(viewModel.currentPassword) ? .red : .clear)
            .font(.uiFootnote)
        }
      }
      Section {
        SecureField(String.newPassword, text: $viewModel.password)
          .textContentType(.password)
          .autocapitalization(.none)
          .autocorrectionDisabled(true)
      } header: {
        Text(String.newPassword)
      } footer: {
        VStack(alignment: .leading) {
          Text("\(viewModel.minimumPasswordLength) characters minimum.")
            .font(.uiFootnote)
          
          if Utility.isBlank(viewModel.password) {
            Text(String.newPasswordIsRequired)
              .foregroundStyle(.red)
              .font(.uiFootnote)
          } else if viewModel.hasInvalidDataPassword {
            Text(String.passwordIsInvalid)
              .foregroundStyle(.red)
              .font(.uiFootnote)
          }
        }
      }
      Section {
        SecureField(String.confirmNewPassword, text: $viewModel.passwordConfirmation)
          .textContentType(.password)
          .autocapitalization(.none)
          .autocorrectionDisabled(true)
      } header: {
        Text(String.confirmNewPassword)
      } footer: {
        Text(String.confirmNewPasswordIsRequired)
          .font(.uiFootnote)
          .foregroundStyle(Utility.isBlank(viewModel.passwordConfirmation) ? .red : .clear)
      }
    }
   .navigationTitle(String.updatePassword)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          viewModel.updatePassword()
        } label: {
          Text(String.save)
        }
        .disabled(viewModel.hasInvalidData)
      }
    }
  }
}
