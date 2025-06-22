//
//  UserAndPasswordView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2020/03/29.
//  Copyright © 2024 Daisuke Adachi All rights reserved.
//

import SwiftUI

struct SignInEmailAndPasswordView: View {
  @Environment(DataManager.self) private var dataManager
  @State private var viewModel: SignInEmailAndPasswordViewModel
  @Environment(MessageBus.self) private var messageBus

  init(
    viewModel: SignInEmailAndPasswordViewModel
  ) {
    self._viewModel = State(initialValue: viewModel)
  }

  var body: some View {
    contentView
  }
}

// MARK: - private
private extension SignInEmailAndPasswordView {
  var contentView: some View {
    @ViewBuilder var contentView: some View {
      if viewModel.isLoggingIn {
        LoadingView()
      } else {
        signInEmailAndPasswordView
      }
    }

    return contentView
  }

  var signInEmailAndPasswordView: some View {
    VStack {
      Form {
        Section {
          TextField(String.placeholderEmail, text: $viewModel.email)
            .textContentType(.emailAddress)
            .autocapitalization(.none)
            .accessibilityIdentifier("SignInEmailAndPasswordView_email_textField")
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
        Section {
          SecureField(String.placeholderPassword, text: $viewModel.password)
            .textContentType(.password)
            .autocapitalization(.none)
            .autocorrectionDisabled(true)
            .accessibilityIdentifier("SignInEmailAndPasswordView_password_secureTextField")
        } header: {
          Text(String.password)
        } footer: {
          if viewModel.isPasswordBlank {
            Text(String.passwordIsRequired)
              .foregroundStyle(.red)
          } else if viewModel.hasInvalidDataPassword {
            Text(String.passwordIsInvalid)
              .foregroundStyle(.red)
          }
        }

        Section {
          MainButtonView(title: String.signIn, type: .primary(withArrow: false)) {
            viewModel.signIn()
          }
          .disabled(viewModel.hasInvalidData)
          .listRowBackground(Color.clear)
        }

        Spacer()
          .listRowBackground(Color.clear)

        NavigationLink(
          destination: ForgotPasswordView(
            viewModel: ForgotPasswordViewModel(
              signUpRepository: dataManager.signUpRepository,
              messageBus: messageBus
            )
          )
        ) {
          Text(String.forgotYourPassword)
        }

        NavigationLink(
          destination: ResendConfirmationInstructionsView(
            viewModel: ResendConfirmationInstructionsViewModel(
              signUpRepository: dataManager.signUpRepository,
              messageBus: messageBus
            )
          )
        ) {
          Text(String.didntReceiveConfirmationInstructions)
        }
      }
    }
    .navigationTitle(String.signIn)
  }
}
