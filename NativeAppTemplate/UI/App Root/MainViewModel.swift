//
//  MainViewModel.swift
//  NativeAppTemplate
//

import Observation
import SwiftUI

/// What MainView shows, from the most to the least blocking condition
enum MainContent: Equatable {
    case onboarding
    case acceptPrivacy
    case acceptTerms
    case permissionsLoading
    case permissionsError
    /// The connection state is not known yet
    case sessionLoading
    case offline
    case rebuildingRepositories
    case needsAppUpdate
    case tabs
}

@Observable
@MainActor
final class MainViewModel {
    private let sessionController: SessionControllerProtocol
    private let messageBus: MessageBus

    init(
        sessionController: SessionControllerProtocol,
        messageBus: MessageBus
    ) {
        self.sessionController = sessionController
        self.messageBus = messageBus
    }

    /// Static so MainView can decide before `onAppear` creates the view model
    static func content(
        sessionController: SessionControllerProtocol,
        isRebuildingRepositories: Bool
    ) -> MainContent {
        guard sessionController.isLoggedIn else { return .onboarding }
        guard !sessionController.shouldUpdatePrivacy else { return .acceptPrivacy }
        guard !sessionController.shouldUpdateTerms else { return .acceptTerms }

        switch sessionController.permissionState {
        case .notLoaded, .loading:
            return .permissionsLoading
        case .error:
            return .permissionsError
        case .loaded:
            break
        }

        switch sessionController.sessionState {
        case .unknown:
            return .sessionLoading
        case .offline:
            return .offline
        case .online:
            if isRebuildingRepositories {
                return .rebuildingRepositories
            } else if sessionController.shouldUpdateApp {
                return .needsAppUpdate
            } else {
                return .tabs
            }
        }
    }

    func logout() {
        Task {
            do {
                try await sessionController.logout()
            } catch {
                messageBus.post(message: Message(error: error))
            }
        }
    }
}
