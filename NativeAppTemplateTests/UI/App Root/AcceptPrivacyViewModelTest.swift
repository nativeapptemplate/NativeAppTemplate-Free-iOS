//
//  AcceptPrivacyViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/21.
//

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
struct AcceptPrivacyViewModelTest {
  let sessionController = TestSessionController()
  let messageBus = MessageBus()

  @Test
  func initialState() {
    let viewModel = AcceptPrivacyViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    #expect(viewModel.isUpdating == false)
    #expect(viewModel.shouldDismiss == false)
    #expect(viewModel.arePrivacyAccepted == false)
  }

  @Test
  func updateConfirmedPrivacyVersion() async {
    let viewModel = AcceptPrivacyViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    viewModel.updateConfirmedPrivacyVersion()

    // Wait for async operation
    try? await Task.sleep(nanoseconds: 100_000_000)

    #expect(viewModel.arePrivacyAccepted == true)
    #expect(viewModel.shouldDismiss == true)
    #expect(messageBus.currentMessage?.level == .success)
  }

  @Test
  func updateConfirmedPrivacyVersionError() async {
    // Set up sessionController to throw an error
    sessionController.shouldThrowPrivacyError = true
    let viewModel = AcceptPrivacyViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    viewModel.updateConfirmedPrivacyVersion()

    try? await Task.sleep(nanoseconds: 100_000_000)

    #expect(viewModel.isUpdating == false)
    #expect(viewModel.arePrivacyAccepted == true) // Still set to true even on error
    #expect(viewModel.shouldDismiss == true) // Still set to true even on error
    #expect(messageBus.currentMessage?.level == .error)
  }

  @Test
  func arePrivacyAcceptedToggle() {
    let viewModel = AcceptPrivacyViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    #expect(viewModel.arePrivacyAccepted == false)

    viewModel.arePrivacyAccepted = true
    #expect(viewModel.arePrivacyAccepted == true)

    viewModel.arePrivacyAccepted = false
    #expect(viewModel.arePrivacyAccepted == false)
  }

  @Test
  func isUpdatingState() {
    let viewModel = AcceptPrivacyViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    #expect(viewModel.isUpdating == false)

    viewModel.isUpdating = true
    #expect(viewModel.isUpdating == true)

    viewModel.isUpdating = false
    #expect(viewModel.isUpdating == false)
  }

  @Test
  func shouldDismissState() {
    let viewModel = AcceptPrivacyViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    #expect(viewModel.shouldDismiss == false)

    viewModel.shouldDismiss = true
    #expect(viewModel.shouldDismiss == true)

    viewModel.shouldDismiss = false
    #expect(viewModel.shouldDismiss == false)
  }
}
