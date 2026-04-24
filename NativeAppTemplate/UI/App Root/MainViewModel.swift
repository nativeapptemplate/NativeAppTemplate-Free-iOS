//
//  MainViewModel.swift
//  NativeAppTemplate
//

import Observation
import SwiftUI

@Observable
@MainActor
final class MainViewModel {
    var arePrivacyAccepted = false
    var areTermsAccepted = false

    private let sessionController: SessionControllerProtocol
    private let dataManager: DataManager
    private let messageBus: MessageBus
    private let tabViewModel: TabViewModel

    init(
        sessionController: SessionControllerProtocol,
        dataManager: DataManager,
        messageBus: MessageBus,
        tabViewModel: TabViewModel
    ) {
        self.sessionController = sessionController
        self.dataManager = dataManager
        self.messageBus = messageBus
        self.tabViewModel = tabViewModel
    }

    func logout() {
        Task {
            try await sessionController.logout()
        }
    }
}
