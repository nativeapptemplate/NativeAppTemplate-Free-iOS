//
//  ShopkeeperEditViewModel.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/15.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class ShopkeeperEditViewModel {
  var name: String
  var email: String
  var selectedTimeZone: String
  var isUpdating = false
  var isDeleting = false
  var isShowingDeleteConfirmationDialog = false
  var shouldDismiss = false
  
  private let signUpRepository: SignUpRepositoryProtocol
  private let sessionController: SessionControllerProtocol
  private let messageBus: MessageBus
  private let tabViewModel: TabViewModel
  private let shopkeeper: Shopkeeper
  
  init(
    signUpRepository: SignUpRepositoryProtocol,
    sessionController: SessionControllerProtocol,
    messageBus: MessageBus,
    tabViewModel: TabViewModel,
    shopkeeper: Shopkeeper
  ) {
    self.signUpRepository = signUpRepository
    self.sessionController = sessionController
    self.messageBus = messageBus
    self.tabViewModel = tabViewModel
    self.shopkeeper = shopkeeper
    self.name = shopkeeper.name
    self.email = shopkeeper.email
    self.selectedTimeZone = shopkeeper.timeZone
  }
  
  var isBusy: Bool {
    isUpdating || isDeleting
  }
  
  var hasInvalidData: Bool {
    if Utility.isBlank(name) {
      return true
    }
    
    if hasInvalidDataEmail {
      return true
    }
    
    if shopkeeper.name == name &&
        shopkeeper.email == email &&
        shopkeeper.timeZone == selectedTimeZone {
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
  
  func updateShopkeeper() {
    let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
    let theName = name.trimmingCharacters(in: whitespacesAndNewlines)
    let theEmail = email.trimmingCharacters(in: whitespacesAndNewlines)
    let emailUpdated = theEmail != shopkeeper.email
    
    Task {
      do {
        isUpdating = true
        
        let signUp = SignUp(
          name: theName,
          email: theEmail,
          timeZone: selectedTimeZone
        )
        let updatedShopkeeper = try await signUpRepository.update(id: shopkeeper.id, signUp: signUp, networkClient: sessionController.client)
        
        var newShopkeeper = sessionController.shopkeeper!
        
        newShopkeeper.email = updatedShopkeeper.email
        newShopkeeper.name = updatedShopkeeper.name
        newShopkeeper.timeZone = updatedShopkeeper.timeZone
        newShopkeeper.uid = updatedShopkeeper.uid
        
        try sessionController.updateShopkeeper(shopkeeper: newShopkeeper)
        
        if emailUpdated {
          messageBus.post(message: Message(level: .success, message: .reconfirmDescription, autoDismiss: false))
          try await sessionController.logout()
        } else {
          messageBus.post(message: Message(level: .success, message: .shopkeeperUpdated))
        }
        
        shouldDismiss = true
      } catch {
        messageBus.post(message: Message(level: .error, message: error.localizedDescription, autoDismiss: false))
      }
      
      isUpdating = false
    }
  }
  
  func destroyShopkeeper() {
    Task {
      isDeleting = true
      
      do {
        try await signUpRepository.destroy(networkClient: sessionController.client)
        messageBus.post(message: Message(level: .success, message: .shopkeeperDeleted))
      } catch {
        messageBus.post(message: Message(level: .error, message: "\(String.shopkeeperDeletedError) \(error.localizedDescription)", autoDismiss: false))
      }
      
      do {
        try sessionController.updateShopkeeper(shopkeeper: nil)
      } catch {
        messageBus.post(message: Message(level: .error, message: "\(String.shopkeeperDeletedError) \(error.localizedDescription)", autoDismiss: false))
      }
      
      isDeleting = false
      // Without this code, error occurs
      tabViewModel.selectedTab = .shops
      shouldDismiss = true
    }
  }
}
