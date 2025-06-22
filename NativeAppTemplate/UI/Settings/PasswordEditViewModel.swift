//
//  PasswordEditViewModel.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/15.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class PasswordEditViewModel {
  var currentPassword = ""
  var password = ""
  var passwordConfirmation = ""
  var isUpdating = false
  var shouldDismiss = false
  
  private let accountPasswordRepository: AccountPasswordRepositoryProtocol
  private let messageBus: MessageBus
  
  init(
    accountPasswordRepository: AccountPasswordRepositoryProtocol,
    messageBus: MessageBus
  ) {
    self.accountPasswordRepository = accountPasswordRepository
    self.messageBus = messageBus
  }
  
  var isBusy: Bool {
    isUpdating
  }
  
  var hasInvalidData: Bool {
    if Utility.isBlank(currentPassword) ||
        Utility.isBlank(password) ||
        Utility.isBlank(passwordConfirmation) {
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
    
    if password.count < .minimumPasswordLength {
      return true
    }
    
    return false
  }
  
  var minimumPasswordLength: Int {
    .minimumPasswordLength
  }
  
  func updatePassword() {
    let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
    let theCurrentPassword = currentPassword.trimmingCharacters(in: whitespacesAndNewlines)
    let thePassword = password.trimmingCharacters(in: whitespacesAndNewlines)
    let thePasswordConfirmation = passwordConfirmation.trimmingCharacters(in: whitespacesAndNewlines)
    
    Task {
      isUpdating = true
      
      do {
        let updatePassword = UpdatePassword(
          currentPassword: theCurrentPassword,
          password: thePassword,
          passwordConfirmation: thePasswordConfirmation
        )
        
        try await accountPasswordRepository.update(updatePassword: updatePassword)
        messageBus.post(message: Message(level: .success, message: .passwordUpdated))
        shouldDismiss = true
      } catch {
        messageBus.post(message: Message(level: .error, message: error.localizedDescription, autoDismiss: false))
      }
      
      isUpdating = false
    }
  }
}
