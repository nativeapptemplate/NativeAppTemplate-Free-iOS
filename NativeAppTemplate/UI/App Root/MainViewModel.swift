//
//  MainViewModel.swift
//  NativeAppTemplate
//

import Observation
import SwiftUI

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
