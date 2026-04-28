//
//  PasswordEditView.swift
//  NativeAppTemplate
//

import SwiftUI

struct PasswordEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PasswordEditViewModel

    init(viewModel: PasswordEditViewModel) {
        _viewModel = State(wrappedValue: viewModel)
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
                SecureField(Strings.currentPassword, text: $viewModel.currentPassword)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
            } header: {
                Text(Strings.currentPassword)
            } footer: {
                VStack(alignment: .leading) {
                    Text(Strings.weNeedYourCurrentPassword)
                        .font(.uiFootnote)
                    Text(Strings.currentPasswordIsRequired)
                        .foregroundStyle(Utility.isBlank(viewModel.currentPassword) ? .validationError : .clear)
                        .font(.uiFootnote)
                }
            }
            Section {
                SecureField(Strings.newPassword, text: $viewModel.password)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
            } header: {
                Text(Strings.newPassword)
            } footer: {
                VStack(alignment: .leading) {
                    Text("\(viewModel.minimumPasswordLength) characters minimum.")
                        .font(.uiFootnote)

                    if Utility.isBlank(viewModel.password) {
                        Text(Strings.newPasswordIsRequired)
                            .foregroundStyle(.validationError)
                            .font(.uiFootnote)
                    } else if viewModel.hasInvalidDataPassword {
                        Text(Strings.passwordIsInvalid)
                            .foregroundStyle(.validationError)
                            .font(.uiFootnote)
                    }
                }
            }
            Section {
                SecureField(Strings.confirmNewPassword, text: $viewModel.passwordConfirmation)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
            } header: {
                Text(Strings.confirmNewPassword)
            } footer: {
                Text(Strings.confirmNewPasswordIsRequired)
                    .font(.uiFootnote)
                    .foregroundStyle(Utility.isBlank(viewModel.passwordConfirmation) ? .validationError : .clear)
            }
        }
        .navigationTitle(Strings.updatePassword)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.updatePassword()
                } label: {
                    Text(Strings.save)
                }
                .disabled(viewModel.hasInvalidData)
            }
        }
    }
}
