//
//  SignUpView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2022/07/08.
//

import SwiftUI

struct SignUpView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var viewModel: SignUpViewModel

  init(
    viewModel: SignUpViewModel
  ) {
    self._viewModel = State(initialValue: viewModel)
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
          TextField(String.placeholderFullName, text: $viewModel.name)
        } header: {
          Text(String.fullName)
        } footer: {
          Text(String.fullNameIsRequired)
            .font(.caption)
            .foregroundStyle(viewModel.isNameBlank ? .red : .clear)
        }

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
          } else if viewModel.hasInvalidDataEmail {
            Text(String.emailIsInvalid)
              .foregroundStyle(.red)
          }
        }

        Picker(String.timeZone, selection: $viewModel.selectedTimeZone) {
          ForEach(timeZones.keys, id: \.self) { key in
            Text(timeZones[key]!).tag(key)
          }
        }

        Section {
          SecureField(String.placeholderPassword, text: $viewModel.password)
            .textContentType(.password)
            .autocapitalization(.none)
            .autocorrectionDisabled(true)
        } header: {
          Text(String.password)
        } footer: {
          VStack(alignment: .leading) {
            Text("\(Int.minimumPasswordLength) characters minimum.")

            if viewModel.isPasswordBlank {
              Text(String.passwordIsRequired)
                .foregroundStyle(.red)
            } else if viewModel.hasInvalidDataPassword {
              Text(String.passwordIsInvalid)
                .foregroundStyle(.red)
            }
          }
        }
        Section {
          MainButtonView(title: String.signUp, type: .primary(withArrow: false)) {
            viewModel.createShopkeeper()
          }
          .disabled(viewModel.hasInvalidData)
          .listRowBackground(Color.clear)
        }
      }
      .navigationTitle(String.signUp)
    }
    .alert(
      String.shopkeeperCreatedError,
      isPresented: $viewModel.isShowingAlert
    ) {
    } message: {
      Text(viewModel.errorMessage)
    }
  }
}
