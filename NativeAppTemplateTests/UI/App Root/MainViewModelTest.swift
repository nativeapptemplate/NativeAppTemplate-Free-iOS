//
//  MainViewModelTest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/21.
//

import Testing
import Foundation
@testable import NativeAppTemplate

@MainActor
@Suite
struct MainViewModelTest {
  let sessionController = TestSessionController()
  let messageBus = MessageBus()

  // Create minimal test versions of complex dependencies
  private func createTestDataManager() -> DataManager {
    return DataManager(sessionController: sessionController)
  }

  private func createTestTabViewModel() -> TabViewModel {
    return TabViewModel()
  }

  @Test
  func initialState() {
    let dataManager = createTestDataManager()
    let tabViewModel = createTestTabViewModel()

    let viewModel = MainViewModel(
      sessionController: sessionController,
      dataManager: dataManager,
      messageBus: messageBus,
      tabViewModel: tabViewModel
    )

    #expect(viewModel.isShowingForceAppUpdatesAlert == false)
    #expect(viewModel.itemTagId == nil)
    #expect(viewModel.isResetting == false)
    #expect(viewModel.isShowingResetConfirmationDialog == false)
    #expect(viewModel.isShowingAcceptPrivacySheet == false)
    #expect(viewModel.arePrivacyAccepted == false)
    #expect(viewModel.isShowingAcceptTermsSheet == false)
    #expect(viewModel.areTermsAccepted == false)
  }

  @Test
  func handlePrivacyUpdate() {
    let dataManager = createTestDataManager()
    let tabViewModel = createTestTabViewModel()

    let viewModel = MainViewModel(
      sessionController: sessionController,
      dataManager: dataManager,
      messageBus: messageBus,
      tabViewModel: tabViewModel
    )

    // Initially should not show privacy sheet
    #expect(viewModel.isShowingAcceptPrivacySheet == false)

    // Set shouldUpdatePrivacy to true
    sessionController.shouldUpdatePrivacy = true

    viewModel.handlePrivacyUpdate()

    #expect(viewModel.isShowingAcceptPrivacySheet == true)

    // Set shouldUpdatePrivacy to false
    sessionController.shouldUpdatePrivacy = false

    viewModel.handlePrivacyUpdate()

    // Should not change the sheet state when false
    #expect(viewModel.isShowingAcceptPrivacySheet == true)
  }

  @Test
  func handleTermsUpdate() {
    let dataManager = createTestDataManager()
    let tabViewModel = createTestTabViewModel()

    let viewModel = MainViewModel(
      sessionController: sessionController,
      dataManager: dataManager,
      messageBus: messageBus,
      tabViewModel: tabViewModel
    )

    // Initially should not show terms sheet
    #expect(viewModel.isShowingAcceptTermsSheet == false)

    // Set shouldUpdateTerms to true
    sessionController.shouldUpdateTerms = true

    viewModel.handleTermsUpdate()

    #expect(viewModel.isShowingAcceptTermsSheet == true)

    // Set shouldUpdateTerms to false
    sessionController.shouldUpdateTerms = false

    viewModel.handleTermsUpdate()

    // Should not change the sheet state when false
    #expect(viewModel.isShowingAcceptTermsSheet == true)
  }

  @Test
  func logout() async {
    let dataManager = createTestDataManager()
    let tabViewModel = createTestTabViewModel()

    let viewModel = MainViewModel(
      sessionController: sessionController,
      dataManager: dataManager,
      messageBus: messageBus,
      tabViewModel: tabViewModel
    )

    // Set initial logged in state
    sessionController.userState = .loggedIn

    viewModel.logout()

    // Wait for async operation
    try? await Task.sleep(nanoseconds: 100_000_000)

    #expect(sessionController.userState == .notLoggedIn)
  }

  @Test
  func resetTagWithoutItemTagId() {
    let dataManager = createTestDataManager()
    let tabViewModel = createTestTabViewModel()

    let viewModel = MainViewModel(
      sessionController: sessionController,
      dataManager: dataManager,
      messageBus: messageBus,
      tabViewModel: tabViewModel
    )

    // Should not reset when itemTagId is nil
    viewModel.itemTagId = nil
    viewModel.resetTag()

    // Nothing should happen
    #expect(viewModel.isResetting == false)
  }

  @Test
  func resetTagWithItemTagId() {
    let dataManager = createTestDataManager()
    let tabViewModel = createTestTabViewModel()

    let viewModel = MainViewModel(
      sessionController: sessionController,
      dataManager: dataManager,
      messageBus: messageBus,
      tabViewModel: tabViewModel
    )

    // Set itemTagId
    viewModel.itemTagId = "test-tag-id"
    // Reset should work with itemTagId set
    viewModel.resetTag()

    // This would trigger async operations in real implementation
    #expect(viewModel.itemTagId == "test-tag-id")
  }

  @Test
  func cancelResetDialog() {
    let dataManager = createTestDataManager()
    let tabViewModel = createTestTabViewModel()

    let viewModel = MainViewModel(
      sessionController: sessionController,
      dataManager: dataManager,
      messageBus: messageBus,
      tabViewModel: tabViewModel
    )

    // Set dialog to showing
    viewModel.isShowingResetConfirmationDialog = true

    viewModel.cancelResetDialog()

    #expect(viewModel.isShowingResetConfirmationDialog == false)
  }

  @Test
  func stateProperties() {
    let dataManager = createTestDataManager()
    let tabViewModel = createTestTabViewModel()

    let viewModel = MainViewModel(
      sessionController: sessionController,
      dataManager: dataManager,
      messageBus: messageBus,
      tabViewModel: tabViewModel
    )

    // Test all boolean state properties
    viewModel.isShowingForceAppUpdatesAlert = true
    #expect(viewModel.isShowingForceAppUpdatesAlert == true)

    viewModel.isResetting = true
    #expect(viewModel.isResetting == true)

    viewModel.isShowingResetConfirmationDialog = true
    #expect(viewModel.isShowingResetConfirmationDialog == true)

    viewModel.isShowingAcceptPrivacySheet = true
    #expect(viewModel.isShowingAcceptPrivacySheet == true)

    viewModel.arePrivacyAccepted = true
    #expect(viewModel.arePrivacyAccepted == true)

    viewModel.isShowingAcceptTermsSheet = true
    #expect(viewModel.isShowingAcceptTermsSheet == true)

    viewModel.areTermsAccepted = true
    #expect(viewModel.areTermsAccepted == true)

    // Test itemTagId
    viewModel.itemTagId = "test-id"
    #expect(viewModel.itemTagId == "test-id")

    viewModel.itemTagId = nil
    #expect(viewModel.itemTagId == nil)
  }
}
