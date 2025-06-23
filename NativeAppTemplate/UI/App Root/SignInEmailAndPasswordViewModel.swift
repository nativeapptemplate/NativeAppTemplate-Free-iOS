//
//  SignInEmailAndPasswordViewModel.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/16.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class SignInEmailAndPasswordViewModel {
  var email = ""
  var password = ""
  var isLoggingIn = false
  
  private let sessionController: SessionControllerProtocol
  private let messageBus: MessageBus
  
  init(
    sessionController: SessionControllerProtocol,
    messageBus: MessageBus
  ) {
    self.sessionController = sessionController
    self.messageBus = messageBus
  }
  
  var hasInvalidData: Bool {
    if Utility.isBlank(email) || Utility.isBlank(password) {
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
  
  var hasInvalidDataPassword: Bool {
    if Utility.isBlank(password) {
      return true
    }
    
    return false
  }
  
  var isEmailBlank: Bool {
    Utility.isBlank(email)
  }
  
  var isEmailInvalid: Bool {
    Utility.isBlank(email) || !Utility.validateEmail(email)
  }
  
  var isPasswordBlank: Bool {
    Utility.isBlank(password)
  }
  
  func signIn() {
    Task {
      let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
      let theEmail = email.trimmingCharacters(in: whitespacesAndNewlines)
      let thePassword = password.trimmingCharacters(in: whitespacesAndNewlines)
      
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
