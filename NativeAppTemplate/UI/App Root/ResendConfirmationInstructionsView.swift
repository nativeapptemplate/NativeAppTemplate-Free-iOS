//
//  ResendConfirmationInstructionsView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/09/30.
//

import SwiftUI

struct ResendConfirmationInstructionsView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var viewModel: ResendConfirmationInstructionsViewModel

  init(
    viewModel: ResendConfirmationInstructionsViewModel
  ) {
    self._viewModel = State(initialValue: viewModel)
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

      MainButtonView(title: String.buttonSendMeConfirmationInstructions, type: .primary(withArrow: false)) {
        viewModel.sendMeConfirmationInstructionsTapped()
      }
      .disabled(viewModel.hasInvalidData)
      .listRowBackground(Color.clear)
    }
    .navigationTitle(String.didntReceiveConfirmationInstructions)
  }
}
