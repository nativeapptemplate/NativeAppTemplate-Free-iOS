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
    func stateProperties() {
        let dataManager = createTestDataManager()
        let tabViewModel = createTestTabViewModel()

        let viewModel = MainViewModel(
            sessionController: sessionController,
            dataManager: dataManager,
            messageBus: messageBus,
            tabViewModel: tabViewModel
        )

        viewModel.arePrivacyAccepted = true
        #expect(viewModel.arePrivacyAccepted == true)

        viewModel.areTermsAccepted = true
        #expect(viewModel.areTermsAccepted == true)
    }
}
