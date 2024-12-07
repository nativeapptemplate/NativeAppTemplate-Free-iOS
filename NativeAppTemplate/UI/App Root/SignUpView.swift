//
//  SignUpView.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2022/07/08.
//

import SwiftUI

struct SignUpView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(SessionController.self) private var sessionController
  @Environment(MessageBus.self) private var messageBus
  private var signUpRepository: SignUpRepository
  @State private var errorMessage: String = ""
  @State private var isCreating = false
  
  @State private var name: String = ""
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var isShowingAlert = false
  @State private var selectedTimeZone: String
  
  init(
    signUpRepository: SignUpRepository
  ) {
    self.signUpRepository = signUpRepository
    _selectedTimeZone = State(initialValue: Utility.currentTimeZone())
  }
  
  var body: some View {
    contentView
  }
  
  private var hasInvalidData: Bool {
    if Utility.isBlank(name) {
      return true
    }
    
    if hasInvalidDataEmail {
      return true
    }
    
    if hasInvalidDataPassword {
      return true
    }
    
    return false
  }
  
  private var hasInvalidDataEmail: Bool {
    if Utility.isBlank(email) {
      return true
    }
    
    if !Utility.validateEmail(email) {
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
}

// MARK: - private
private extension SignUpView {
  var contentView: some View {
    
    @ViewBuilder var contentView: some View {
      if isCreating {
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
          TextField(String.placeholderFullName, text: $name)
        } header: {
          Text(String.fullName)
        } footer: {
          Text(String.fullNameIsRequired)
            .font(.caption)
            .foregroundStyle(Utility.isBlank(name) ? .red : .clear)
        }
        
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
          } else if hasInvalidDataEmail {
            Text(String.emailIsInvalid)
              .foregroundStyle(.red)
          }
        }
        
        Picker(String.timeZone, selection: $selectedTimeZone) {
          ForEach(timeZones.keys, id: \.self) { key in
            Text(timeZones[key]!).tag(key)
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
          VStack(alignment: .leading) {
            Text("\(Int.minimumPasswordLength) characters minimum.")
            
            if Utility.isBlank(password) {
              Text(String.passwordIsRequired)
                .foregroundStyle(.red)
            } else if hasInvalidDataPassword {
              Text(String.passwordIsInvalid)
                .foregroundStyle(.red)
            }
          }
        }
        Section {
          MainButtonView(title: String.signUp, type: .primary(withArrow: false)) {
            createShopkeeper()
          }
          .disabled(hasInvalidData)
          .listRowBackground(Color.clear)
        }
      }
      .navigationTitle(String.signUp)
    }
    .alert(
      String.shopkeeperCreatedError,
      isPresented: $isShowingAlert
    ) {
    } message: {
      Text(errorMessage)
    }
  }
  
  func createShopkeeper() {
    let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
    let theName = name.trimmingCharacters(in: whitespacesAndNewlines)
    let theEmail = email.trimmingCharacters(in: whitespacesAndNewlines)
    let thePassword = password.trimmingCharacters(in: whitespacesAndNewlines)
    
    Task { @MainActor in
      isCreating = true
      
      do {
        let signUp = SignUp(
          name: theName,
          email: theEmail,
          timeZone: selectedTimeZone,
          password: thePassword
        )
        _ = try await signUpRepository.signUp(signUp: signUp)
        
        messageBus.post(message: Message(level: .error, message: String.signedUpButUnconfirmed, autoDismiss: false))
        dismiss()
      } catch NativeAppTemplateAPIError.requestFailed(_, _, let message) {
        errorMessage = message ?? "UNKNOWN"
        isShowingAlert = true
      } catch {
        errorMessage = error.localizedDescription
        isShowingAlert = true
      }
      
      isCreating = false
    }
  }
}
