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
}
