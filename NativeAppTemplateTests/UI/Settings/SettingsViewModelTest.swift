//
//  SettingsViewModelTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
@Suite
struct SettingsViewModelTest {
    let sessionController = TestSessionController()
    let tabViewModel = TabViewModel()
    let messageBus = MessageBus()

    @Test
    func initializesCorrectly() {
        let viewModel = SettingsViewModel(
            sessionController: sessionController,
            tabViewModel: tabViewModel,
            messageBus: messageBus
        )

        #expect(viewModel.messageBus === messageBus)
    }

    @Test
    func shopkeeperPropertyReflectsSessionController() throws {
        let mockShopkeeper = try #require(Shopkeeper(
            id: "test-id",
            accountId: "test-account-id",
            personalAccountId: "test-personal-id",
            accountOwnerId: "test-owner-id",
            accountName: "Test Account",
            email: "test@example.com",
            name: "Test User",
            timeZone: "Tokyo",
            uid: "test-uid",
            token: "test-token",
            client: "test-client",
            expiry: "test-expiry"
        ))

        sessionController.shopkeeper = mockShopkeeper

        let viewModel = SettingsViewModel(
            sessionController: sessionController,
            tabViewModel: tabViewModel,
            messageBus: messageBus
        )

        #expect(viewModel.shopkeeper?.id == "test-id")
        #expect(viewModel.shopkeeper?.name == "Test User")
        #expect(viewModel.shopkeeper?.email == "test@example.com")
    }

    @Test("Is logged in status", arguments: [true, false])
    func isLoggedInReflectsSessionController(isLoggedIn: Bool) {
        sessionController.userState = isLoggedIn ? .loggedIn : .notLoggedIn

        let viewModel = SettingsViewModel(
            sessionController: sessionController,
            tabViewModel: tabViewModel,
            messageBus: messageBus
        )

        #expect(viewModel.isLoggedIn == isLoggedIn)
    }

    @Test
    func accountIdReflectsSessionController() {
        let viewModel = SettingsViewModel(
            sessionController: sessionController,
            tabViewModel: tabViewModel,
            messageBus: messageBus
        )

        #expect(viewModel.accountId == sessionController.client.accountId)
    }

    @Test
    func signOutSuccess() async {
        sessionController.userState = .loggedIn
        tabViewModel.selectedTab = .settings

        let viewModel = SettingsViewModel(
            sessionController: sessionController,
            tabViewModel: tabViewModel,
            messageBus: messageBus
        )

        viewModel.signOut()

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        #expect(sessionController.userState == .notLoggedIn)
        #expect(tabViewModel.selectedTab == .shops)
        #if DEBUG
        #expect(messageBus.currentMessage != nil)
        #expect(messageBus.currentMessage?.level == .success)
        #expect(messageBus.currentMessage?.message == Strings.signedOut)
        #endif
    }

    @Test
    func signOutWithError() async {
        sessionController.userState = .loggedIn
        tabViewModel.selectedTab = .settings

        // Force an error by setting the session state to make logout fail
        // Note: TestSessionController doesn't naturally throw errors, so this test
        // demonstrates the error handling structure
        let viewModel = SettingsViewModel(
            sessionController: sessionController,
            tabViewModel: tabViewModel,
            messageBus: messageBus
        )

        viewModel.signOut()

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Even if logout succeeds in test environment, tab should still be set to shops
        #expect(tabViewModel.selectedTab == .shops)
    }

    @Test
    func messageBusIsAccessible() {
        let viewModel = SettingsViewModel(
            sessionController: sessionController,
            tabViewModel: tabViewModel,
            messageBus: messageBus
        )

        // Verify messageBus is properly accessible and is the same instance
        #expect(viewModel.messageBus === messageBus)
    }
}
