//
//  AcceptPrivacyViewModel.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/16.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class AcceptPrivacyViewModel {
  var isUpdating = false
  var shouldDismiss = false
  var arePrivacyAccepted = false

  private let sessionController: SessionControllerProtocol
  private let messageBus: MessageBus
  
  init(
    sessionController: SessionControllerProtocol,
    messageBus: MessageBus
  ) {
    self.sessionController = sessionController
    self.messageBus = messageBus
  }
  
  func updateConfirmedPrivacyVersion() {
    Task { @MainActor in
      do {
        isUpdating = true
        try await sessionController.updateConfirmedPrivacyVersion()
         messageBus.post(message: Message(level: .success, message: .confirmedPrivacyVersionUpdated))
      } catch {
        messageBus.post(message: Message(level: .error, message: "\(String.confirmedPrivacyVersionUpdatedError) \(error.localizedDescription)", autoDismiss: false))
      }

      arePrivacyAccepted = true
      shouldDismiss = true
      isUpdating = false
    }
  }
}
