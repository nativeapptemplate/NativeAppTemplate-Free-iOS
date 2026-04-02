//
//  MainViewModelTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
@Suite
struct MainViewModelTest {
    let sessionController = TestSessionController()
    let messageBus = MessageBus()

    /// Create minimal test versions of complex dependencies
    private func createTestDataManager() -> DataManager {
        DataManager(sessionController: sessionController)
    }

    private func createTestTabViewModel() -> TabViewModel {
        TabViewModel()
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
        #expect(viewModel.arePrivacyAccepted == false)
        #expect(viewModel.areTermsAccepted == false)
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

        viewModel.arePrivacyAccepted = true
        #expect(viewModel.arePrivacyAccepted == true)

        viewModel.areTermsAccepted = true
        #expect(viewModel.areTermsAccepted == true)

        // Test itemTagId
        viewModel.itemTagId = "test-id"
        #expect(viewModel.itemTagId == "test-id")

        viewModel.itemTagId = nil
        #expect(viewModel.itemTagId == nil)
    }
}
