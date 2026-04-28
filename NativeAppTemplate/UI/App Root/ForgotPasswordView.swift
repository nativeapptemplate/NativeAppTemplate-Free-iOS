//
//  ForgotPasswordView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ForgotPasswordViewModel

    init(
        viewModel: ForgotPasswordViewModel
    ) {
        _viewModel = State(initialValue: viewModel)
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
                TextField(Strings.placeholderEmail, text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
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

            MainButtonView(title: Strings.buttonSendMeResetPasswordInstructions, type: .primary(withArrow: false)) {
                viewModel.sendMeResetPasswordInstructionsTapped()
            }
            .disabled(viewModel.hasInvalidData)
            .listRowBackground(Color.clear)
        }
        .navigationTitle(Strings.forgotYourPassword)
    }
}
