//
//  AcceptTermsViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/21.
//

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
struct AcceptTermsViewModelTest {
  let sessionController = TestSessionController()
  let messageBus = MessageBus()

  @Test
  func initialState() {
    let viewModel = AcceptTermsViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    #expect(viewModel.isUpdating == false)
    #expect(viewModel.shouldDismiss == false)
    #expect(viewModel.areTermsAccepted == false)
  }

  @Test
  func updateConfirmedTermsVersion() async {
    let viewModel = AcceptTermsViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    viewModel.updateConfirmedTermsVersion()

    // Wait for async operation
    try? await Task.sleep(nanoseconds: 100_000_000)

    #expect(viewModel.areTermsAccepted == true)
    #expect(viewModel.shouldDismiss == true)
    #expect(messageBus.currentMessage?.level == .success)
  }

  @Test
  func updateConfirmedTermsVersionError() async {
    // Set up sessionController to throw an error
    sessionController.shouldThrowTermsError = true
    let viewModel = AcceptTermsViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    viewModel.updateConfirmedTermsVersion()

    try? await Task.sleep(nanoseconds: 100_000_000)

    #expect(viewModel.isUpdating == false)
    #expect(viewModel.areTermsAccepted == true) // Still set to true even on error
    #expect(viewModel.shouldDismiss == true) // Still set to true even on error
    #expect(messageBus.currentMessage?.level == .error)
  }

  @Test
  func areTermsAcceptedToggle() {
    let viewModel = AcceptTermsViewModel(
      sessionController: sessionController,
      messageBus: messageBus
    )

    #expect(viewModel.areTermsAccepted == false)

    viewModel.areTermsAccepted = true
    #expect(viewModel.areTermsAccepted == true)

    viewModel.areTermsAccepted = false
    #expect(viewModel.areTermsAccepted == false)
  }

  @Test
  func isUpdatingState() {
    let viewModel = AcceptTermsViewModel(
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
    let viewModel = AcceptTermsViewModel(
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
