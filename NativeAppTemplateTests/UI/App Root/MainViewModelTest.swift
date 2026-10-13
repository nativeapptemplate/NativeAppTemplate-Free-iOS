//
//  MainViewModelTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
struct MainViewModelTest {
    let sessionController = TestSessionController()
    let messageBus = MessageBus()

    @Test
    func logout() async {
        let viewModel = MainViewModel(
            sessionController: sessionController,
            messageBus: messageBus
        )

        sessionController.userState = .loggedIn

        viewModel.logout()

        await waitUntil { sessionController.userState == .notLoggedIn }

        #expect(sessionController.userState == .notLoggedIn)
    }
}
