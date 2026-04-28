//
//  ResendConfirmationInstructionsView.swift
//  NativeAppTemplate
//

import SwiftUI

struct ResendConfirmationInstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ResendConfirmationInstructionsViewModel

    init(
        viewModel: ResendConfirmationInstructionsViewModel
    ) {
        _viewModel = State(initialValue: viewModel)
    }
}

extension ResendConfirmationInstructionsView {
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

private extension ResendConfirmationInstructionsView {
    var contentView: some View {
        @ViewBuilder var contentView: some View {
            if viewModel.isSendingConfirmationInstructions {
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

            MainButtonView(title: Strings.buttonSendMeConfirmationInstructions, type: .primary(withArrow: false)) {
                viewModel.sendMeConfirmationInstructionsTapped()
            }
            .disabled(viewModel.hasInvalidData)
            .listRowBackground(Color.clear)
        }
        .navigationTitle(Strings.didntReceiveConfirmationInstructions)
    }
}
