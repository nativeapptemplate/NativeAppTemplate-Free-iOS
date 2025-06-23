//
//  ForgotPasswordView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/03/02.
//

import SwiftUI

struct ForgotPasswordView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var viewModel: ForgotPasswordViewModel

  init(
    viewModel: ForgotPasswordViewModel
  ) {
    self._viewModel = State(initialValue: viewModel)
  }
}

extension ForgotPasswordView {
  var body: some View {
    contentView
      .onChange(of: viewModel.shouldDismiss) {
        if viewModel.shouldDismiss {
          dismiss()
        }
      }
  }
}

// MARK: - private
private extension ForgotPasswordView {
  var contentView: some View {

    @ViewBuilder var contentView: some View {
      if viewModel.isSendingResetPasswordInstructions {
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
        TextField(String.placeholderEmail, text: $viewModel.email)
          .textContentType(.emailAddress)
          .autocapitalization(.none)
       } header: {
        Text(String.email)
      } footer: {
        if viewModel.isEmailBlank {
          Text(String.emailIsRequired)
            .foregroundStyle(.red)
        } else if viewModel.isEmailInvalid {
          Text(String.emailIsInvalid)
            .foregroundStyle(.red)
        }
      }

      MainButtonView(title: String.buttonSendMeResetPasswordInstructions, type: .primary(withArrow: false)) {
        viewModel.sendMeResetPasswordInstructionsTapped()
      }
      .disabled(viewModel.hasInvalidData)
      .listRowBackground(Color.clear)
    }
    .navigationTitle(String.forgotYourPassword)
  }
}
