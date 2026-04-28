//
//  SignUpView.swift
//  NativeAppTemplate
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SignUpViewModel

    init(
        viewModel: SignUpViewModel
    ) {
        _viewModel = State(initialValue: viewModel)
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

private extension SignUpView {
    var contentView: some View {
        @ViewBuilder var contentView: some View {
            if viewModel.isCreating {
                LoadingView()
            } else {
                signUpView
            }
        }

        return contentView
    }

    var signUpView: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(Strings.placeholderFullName, text: $viewModel.name)
                } header: {
                    Text(Strings.fullName)
                } footer: {
                    Text(Strings.fullNameIsRequired)
                        .font(.caption)
                        .foregroundStyle(viewModel.isNameBlank ? .validationError : .clear)
                }

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
                    } else if viewModel.hasInvalidDataEmail {
                        Text(Strings.emailIsInvalid)
                            .foregroundStyle(.validationError)
                    }
                }

                Picker(Strings.timeZone, selection: $viewModel.selectedTimeZone) {
                    ForEach(timeZones.keys, id: \.self) { key in
                        Text(timeZones[key]!).tag(key)
                    }
                }

                Section {
                    SecureField(Strings.placeholderPassword, text: $viewModel.password)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                } header: {
                    Text(Strings.password)
                } footer: {
                    VStack(alignment: .leading) {
                        Text("\(Int.minimumPasswordLength) characters minimum.")

                        if viewModel.isPasswordBlank {
                            Text(Strings.passwordIsRequired)
                                .foregroundStyle(.validationError)
                        } else if viewModel.hasInvalidDataPassword {
                            Text(Strings.passwordIsInvalid)
                                .foregroundStyle(.validationError)
                        }
                    }
                }
                Section {
                    MainButtonView(title: Strings.signUp, type: .primary(withArrow: false)) {
                        viewModel.createShopkeeper()
                    }
                    .disabled(viewModel.hasInvalidData)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle(Strings.signUp)
        }
        .alert(
            Strings.shopkeeperCreatedError,
            isPresented: $viewModel.isShowingAlert
        ) {} message: {
            Text(viewModel.errorMessage)
        }
    }
}
