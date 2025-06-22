//
//  SignUpViewModel.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/16.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class SignUpViewModel {
  var name = ""
  var email = ""
  var password = ""
  var selectedTimeZone: String
  var isCreating = false
  var errorMessage = ""
  var isShowingAlert = false
  var shouldDismiss = false
  
  private let signUpRepository: SignUpRepositoryProtocol
  private let messageBus: MessageBus
  
  init(
    signUpRepository: SignUpRepositoryProtocol,
    messageBus: MessageBus
  ) {
    self.signUpRepository = signUpRepository
    self.messageBus = messageBus
    self.selectedTimeZone = Utility.currentTimeZone()
  }
  
  var hasInvalidData: Bool {
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
  
  var hasInvalidDataEmail: Bool {
    if Utility.isBlank(email) {
      return true
    }
    
    if !Utility.validateEmail(email) {
      return true
    }
    
    return false
  }
  
  var hasInvalidDataPassword: Bool {
    if Utility.isBlank(password) {
      return true
    }
    
    if password.count < .minimumPasswordLength {
      return true
    }
    
    return false
  }
  
  var isNameBlank: Bool {
    Utility.isBlank(name)
  }
  
  var isEmailBlank: Bool {
    Utility.isBlank(email)
  }
  
  var isPasswordBlank: Bool {
    Utility.isBlank(password)
  }
  
  func createShopkeeper() {
    Task {
      let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
      let theName = name.trimmingCharacters(in: whitespacesAndNewlines)
      let theEmail = email.trimmingCharacters(in: whitespacesAndNewlines)
      let thePassword = password.trimmingCharacters(in: whitespacesAndNewlines)
      
      isCreating = true
      
      do {
        let signUp = SignUp(
          name: theName,
          email: theEmail,
          timeZone: selectedTimeZone,
          password: thePassword
        )
        _ = try await signUpRepository.signUp(signUp: signUp)
        
        messageBus.post(message: Message(level: .success, message: String.signedUpButUnconfirmed, autoDismiss: false))
        shouldDismiss = true
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
