//
//  UserAndPasswordView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2020/03/29.
//  Copyright © 2024 Daisuke Adachi All rights reserved.
//

import SwiftUI

struct SignInEmailAndPasswordView: View {
  @Environment(MessageBus.self) private var messageBus
  @Environment(SessionController.self) private var sessionController
  let signUpRepository: SignUpRepository
  
  @State var email: String = ""
  @State var password: String = ""
  @State private var isLoggingIn = false
  
  private var hasInvalidData: Bool {
    if Utility.isBlank(email) ||
        Utility.isBlank(password) {
      return true
    }
    
    if !Utility.validateEmail(email) {
      return true
    }

    if hasInvalidDataPassword {
      return true
    }

    return false
  }

  private var hasInvalidDataPassword: Bool {
    if Utility.isBlank(password) {
      return true
    }

    if password.count < .minimumPasswordLength {
      return true
    }

    return false
  }

  var body: some View {
    contentView
  }
}

// MARK: - private
private extension SignInEmailAndPasswordView {
  var contentView: some View {
    @ViewBuilder var contentView: some View {
      if isLoggingIn {
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
          TextField(String.placeholderEmail, text: $email)
            .textContentType(.emailAddress)
            .autocapitalization(.none)
        } header: {
          Text(String.email)
        } footer: {
          if Utility.isBlank(email) {
            Text(String.emailIsRequired)
              .foregroundStyle(.red)
          } else if !Utility.validateEmail(email) {
            Text(String.emailIsInvalid)
              .foregroundStyle(.red)
          }
        }
        Section {
          SecureField(String.placeholderPassword, text: $password)
            .textContentType(.password)
            .autocapitalization(.none)
            .autocorrectionDisabled(true)
        } header: {
          Text(String.password)
        } footer: {
          if Utility.isBlank(password) {
            Text(String.passwordIsRequired)
              .foregroundStyle(.red)
          } else if hasInvalidDataPassword {
            Text(String.passwordIsInvalid)
              .foregroundStyle(.red)
          }
        }
        
        Section {
          MainButtonView(title: String.signIn, type: .primary(withArrow: false)) {
            signInTapped()
          }
          .disabled(hasInvalidData)
          .listRowBackground(Color.clear)
        }
        
        Spacer()
          .listRowBackground(Color.clear)
        
        NavigationLink(
          destination: ForgotPasswordView(signUpRepository: signUpRepository)
        ) {
          Text(String.forgotYourPassword)
        }
        
        NavigationLink(
          destination: ResendConfirmationInstructionsView(signUpRepository: signUpRepository)
        ) {
          Text(String.didntReceiveConfirmationInstructions)
        }
      }
    }
    .navigationTitle(String.signIn)
  }
  
  private func signInTapped() {
    let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
    let theEmail = email.trimmingCharacters(in: whitespacesAndNewlines)
    let thePassword = password.trimmingCharacters(in: whitespacesAndNewlines)
    
    Task { @MainActor in
      do {
        isLoggingIn = true
        try await sessionController.login(email: theEmail, password: thePassword)
      } catch {
        messageBus.post(
          message: Message(
            level: .error,
            message: error.localizedDescription,
            autoDismiss: false
          )
        )
      }
      
      isLoggingIn = false
    }
  }
}
