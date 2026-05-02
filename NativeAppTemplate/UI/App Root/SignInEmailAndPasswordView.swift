//
//  SignInEmailAndPasswordView.swift
//  NativeAppTemplate
//

import SwiftUI

struct SignInEmailAndPasswordView: View {
    @Environment(DataManager.self) private var dataManager
    @State private var viewModel: SignInEmailAndPasswordViewModel
    @Environment(MessageBus.self) private var messageBus

    init(
        viewModel: SignInEmailAndPasswordViewModel
    ) {
        _viewModel = State(initialValue: viewModel)
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
                    TextField(Strings.placeholderEmail, text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .accessibilityIdentifier("SignInEmailAndPasswordView_email_textField")
                } header: {
                    Text(Strings.email)
                } footer: {
                    if viewModel.isEmailBlank {
                        Text(Strings.emailIsRequired)
                            .foregroundStyle(.validationError)
                    } else if viewModel.isEmailInvalid {
                        Text(Strings.emailIsInvalid)
                            .foregroundStyle(.validationError)
                    }
                }
                Section {
                    SecureField(Strings.placeholderPassword, text: $viewModel.password)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                        .accessibilityIdentifier("SignInEmailAndPasswordView_password_secureTextField")
                } header: {
                    Text(Strings.password)
                } footer: {
                    if viewModel.isPasswordBlank {
                        Text(Strings.passwordIsRequired)
                            .foregroundStyle(.validationError)
                    } else if viewModel.hasInvalidDataPassword {
                        Text(Strings.passwordIsInvalid)
                            .foregroundStyle(.validationError)
                    }
                }

                Section {
                    MainButtonView(title: Strings.signIn, type: .primary(withArrow: false)) {
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
                    Text(Strings.forgotYourPassword)
                }

                NavigationLink(
                    destination: ResendConfirmationInstructionsView(
                        viewModel: ResendConfirmationInstructionsViewModel(
                            signUpRepository: dataManager.signUpRepository,
                            messageBus: messageBus
                        )
                    )
                ) {
                    Text(Strings.didntReceiveConfirmationInstructions)
                }
            }
        }
        .navigationTitle(Strings.signIn)
    }
}
