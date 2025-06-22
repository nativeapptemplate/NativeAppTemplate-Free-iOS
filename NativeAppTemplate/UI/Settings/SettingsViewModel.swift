//
//  SettingsViewModel.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/04/20.
//

import SwiftUI
import Observation
import MessageUI

@Observable
@MainActor
final class SettingsViewModel {
  var isShowingMailView = false
  var alertNoMail = false
  var result: Result<MFMailComposeResult, Error>?
  private(set) var messageBus: MessageBus

  private let sessionController: SessionControllerProtocol
  private let tabViewModel: TabViewModel
  
  init(
    sessionController: SessionControllerProtocol,
    tabViewModel: TabViewModel,
    messageBus: MessageBus
  ) {
    self.sessionController = sessionController
    self.tabViewModel = tabViewModel
    self.messageBus = messageBus
  }
  
  var shopkeeper: Shopkeeper? { sessionController.shopkeeper }
  var isLoggedIn: Bool { sessionController.isLoggedIn }
  var accountId: String { sessionController.client.accountId }
  
  func signOut() {
    Task { @MainActor in
      do {
        try await sessionController.logout()
#if DEBUG
        messageBus.post(message: Message(level: .success, message: .signedOut))
#endif
      } catch {
#if DEBUG
        messageBus.post(message: Message(level: .error, message: "\(String.signedOutError) \(error.localizedDescription)", autoDismiss: false))
#endif
      }
      
      tabViewModel.selectedTab = .shops
    }
  }
} 
