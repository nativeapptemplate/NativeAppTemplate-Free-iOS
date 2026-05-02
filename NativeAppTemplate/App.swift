//
//  App.swift
//  NativeAppTemplate
//

import Foundation
import SwiftUI
import TipKit

extension EnvironmentValues {
    @Entry var sessionController: any SessionControllerProtocol = MainActor.assumeIsolated {
        NullSessionController()
    }
}

/// Null object pattern for default value
@MainActor
private final class NullSessionController: SessionControllerProtocol {
    var sessionState: SessionState {
        .unknown
    }

    var userState: UserState {
        .notLoggedIn
    }

    var permissionState: PermissionState {
        .notLoaded
    }

    var didFetchPermissions: Bool {
        false
    }

    var shouldPopToRootView: Bool = false
    var shouldUpdateApp: Bool = false
    var shouldUpdatePrivacy: Bool = false
    var shouldUpdateTerms: Bool = false
    var shopLimitCount: Int = 0
    var shopkeeper: Shopkeeper?
    var hasPermissions: Bool {
        false
    }

    var isLoggedIn: Bool {
        false
    }

    var client: NativeAppTemplateAPI {
        NativeAppTemplateAPI()
    }

    func login(email: String, password: String) async throws {}
    func logout() async throws {}
    func fetchPermissionsIfNeeded() {}
    func fetchPermissions() {}
    func updateShopkeeper(shopkeeper: Shopkeeper?) throws {}
    func updateConfirmedPrivacyVersion() async throws {}
    func updateConfirmedTermsVersion() async throws {}
}

@main
struct App {
    typealias Objects = ( // swiftlint:disable:this large_tuple
        loginRepository: LoginRepository,
        sessionController: SessionController,
        dataManager: DataManager,
        messageBus: MessageBus
    )

    private var loginRepository: LoginRepository
    private var sessionController: SessionController
    private var dataManager: DataManager
    private var messageBus: MessageBus

    @MainActor init() {
        // setup objects
        let nativeAppTemplateObjects = App.objects
        loginRepository = nativeAppTemplateObjects.loginRepository
        sessionController = nativeAppTemplateObjects.sessionController
        dataManager = nativeAppTemplateObjects.dataManager
        messageBus = nativeAppTemplateObjects.messageBus

//    Tips.showAllTipsForTesting()

        try? Tips.configure()
    }
}

// MARK: - SwiftUI.App

extension App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                Rectangle()
                    .fill(Color.backgroundColor)
                    .edgesIgnoringSafeArea(.all)
                MainView()
                    .preferredColorScheme(.dark) // Dark mode only
                    .environment(loginRepository)
                    .environment(\.sessionController, sessionController)
                    .environment(dataManager)
                    .environment(messageBus)
            }
        }
    }
}

// MARK: - internal

extension App {
    /// Initialise the database
    @MainActor static var objects: Objects {
        let loginRepository = LoginRepository()
        let sessionController = SessionController(loginRepository: loginRepository)
        let messageBus = MessageBus()

        return (
            loginRepository: loginRepository,
            sessionController: sessionController,
            dataManager: .init(
                sessionController: sessionController
            ),
            messageBus: messageBus
        )
    }
}
