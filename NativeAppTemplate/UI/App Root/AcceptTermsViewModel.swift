//
//  AcceptTermsViewModel.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/16.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class AcceptTermsViewModel {
  var isUpdating = false
  var shouldDismiss = false
  var areTermsAccepted = false

  private let sessionController: SessionControllerProtocol
  private let messageBus: MessageBus

  init(
    sessionController: SessionControllerProtocol,
    messageBus: MessageBus
  ) {
    self.sessionController = sessionController
    self.messageBus = messageBus
  }

  func updateConfirmedTermsVersion() {
    Task { @MainActor in
      do {
        isUpdating = true
        try await sessionController.updateConfirmedTermsVersion()
         messageBus.post(message: Message(level: .success, message: .confirmedTermsVersionUpdated))
      } catch {
        messageBus.post(message: Message(level: .error, message: "\(String.confirmedTermsVersionUpdatedError) \(error.localizedDescription)", autoDismiss: false))
      }

      areTermsAccepted = true
      shouldDismiss = true
      isUpdating = false
    }
  }
}
