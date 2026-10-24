//
//  MainContentTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// MainViewModel.content: which screen MainView shows. The expected order is
/// MainView's gating before it moved into the view model: sign-in, then privacy,
/// then terms, then permissions, then the connection, then rebuilding, then the
/// required app update.
@MainActor
struct MainContentTest {
    let sessionController = TestSessionController()

    /// Signed in, permissions loaded, online, nothing to accept: the app's tabs
    private func readySessionController() -> TestSessionController {
        sessionController.userState = .loggedIn
        sessionController.permissionState = .loaded
        sessionController.sessionState = .online
        return sessionController
    }

    private func content(isRebuildingRepositories: Bool = false) -> MainContent {
        MainViewModel.content(
            sessionController: sessionController,
            isRebuildingRepositories: isRebuildingRepositories
        )
    }

    @Test
    func readySessionShowsTheTabs() {
        _ = readySessionController()

        #expect(content() == .tabs)
    }

    @Test
    func signedOutShowsOnboardingWhateverElseIsSet() {
        _ = readySessionController()
        sessionController.userState = .notLoggedIn
        sessionController.shouldUpdatePrivacy = true
        sessionController.shouldUpdateTerms = true
        sessionController.shouldUpdateApp = true

        #expect(content(isRebuildingRepositories: true) == .onboarding)
    }

    @Test
    func privacyComesBeforeTerms() {
        _ = readySessionController()
        sessionController.shouldUpdatePrivacy = true
        sessionController.shouldUpdateTerms = true

        #expect(content() == .acceptPrivacy)
    }

    @Test
    func termsComeBeforePermissionsAndTheConnection() {
        _ = readySessionController()
        sessionController.shouldUpdateTerms = true
        sessionController.permissionState = .error
        sessionController.sessionState = .offline

        #expect(content() == .acceptTerms)
    }

    @Test(arguments: [PermissionState.notLoaded, .loading])
    func unloadedPermissionsShowThePermissionsLoadingScreen(permissionState: PermissionState) {
        _ = readySessionController()
        sessionController.permissionState = permissionState
        sessionController.sessionState = .offline

        #expect(content() == .permissionsLoading)
    }

    @Test
    func permissionErrorComesBeforeTheConnection() {
        _ = readySessionController()
        sessionController.permissionState = .error
        sessionController.sessionState = .offline

        #expect(content() == .permissionsError)
    }

    @Test
    func unknownConnectionShowsLoading() {
        _ = readySessionController()
        sessionController.sessionState = .unknown

        #expect(content(isRebuildingRepositories: true) == .sessionLoading)
    }

    @Test
    func offlineComesBeforeRebuildingAndTheAppUpdate() {
        _ = readySessionController()
        sessionController.sessionState = .offline
        sessionController.shouldUpdateApp = true

        #expect(content(isRebuildingRepositories: true) == .offline)
    }

    @Test
    func rebuildingComesBeforeTheAppUpdate() {
        _ = readySessionController()
        sessionController.shouldUpdateApp = true

        #expect(content(isRebuildingRepositories: true) == .rebuildingRepositories)
    }

    @Test
    func requiredUpdateShowsTheUpdateScreen() {
        _ = readySessionController()
        sessionController.shouldUpdateApp = true

        #expect(content() == .needsAppUpdate)
    }

    /// MainView shows the message bar over the whole screen only without a tab bar;
    /// with one, each tab shows it above the tab bar (it covered the tab bar and
    /// blocked tab taps until closed). The cases with a tab bar are the ones
    /// MainView.contentView shows in AppTabView.
    @Test
    func contentInAppTabViewHasATabBar() {
        let withTabBar: [MainContent] = [.offline, .rebuildingRepositories, .needsAppUpdate, .tabs]
        let withoutTabBar: [MainContent] = [
            .onboarding, .acceptPrivacy, .acceptTerms, .permissionsLoading, .permissionsError, .sessionLoading
        ]

        #expect(withTabBar.allSatisfy { $0.hasTabBar })
        #expect(!withoutTabBar.contains { $0.hasTabBar })
    }

    /// Offline keeps the screens under OfflineView: replacing them closed the sheet a
    /// screen had open, with what was typed in it. Loading and needing an update still
    /// replace them; without a tab bar there is nothing to cover
    @Test
    func tabCoverFollowsTheContent() {
        #expect(MainContent.tabs.tabCover == .uncovered)
        #expect(MainContent.offline.tabCover == .offline)
        #expect(MainContent.rebuildingRepositories.tabCover == .loading)
        #expect(MainContent.needsAppUpdate.tabCover == .needsAppUpdate)
        #expect(MainContent.offline.tabCover?.keepsScreens == true)
        #expect(MainContent.rebuildingRepositories.tabCover?.keepsScreens == false)
        #expect(MainContent.onboarding.tabCover == nil)
    }
}
