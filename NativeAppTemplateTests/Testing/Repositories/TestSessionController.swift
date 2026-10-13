//
//  TestSessionController.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate

@MainActor @Observable public class TestSessionController: SessionControllerProtocol {
    // MARK: - Properties

    public var sessionState: SessionState = .unknown
    public var userState: UserState = .loggedIn
    public var permissionState: PermissionState = .notLoaded

    public var shouldPopToRootView: Bool = false
    public var didExpireSession: Bool = false

    public var shouldUpdateApp: Bool = false
    public var shouldUpdatePrivacy: Bool = false
    public var shouldUpdateTerms: Bool = false
    public var shouldThrowPrivacyError: Bool = false
    public var shouldThrowTermsError: Bool = false
    public var shopLimitCount: Int = 1

    public var shopkeeper: Shopkeeper?
    /// Points at a closed local port, so a repository built from it (DataManager)
    /// fails at once instead of sending requests to the configured API. Tests
    /// that want a server set it to TestHTTPServer.client().
    public var client = NativeAppTemplateAPI(
        // NativeAppTemplateEnvironment.swift is also compiled into the test target
        environment: NativeAppTemplate.NativeAppTemplateEnvironment(baseURL: URL(string: "http://127.0.0.1:1")!),
        authToken: "",
        client: "",
        expiry: "",
        uid: "",
        accountId: ""
    )

    public var isLoggedIn: Bool {
        userState == .loggedIn
    }

    // MARK: - Initializer

    public nonisolated init() {}

    // MARK: - Methods

    public func login(email: String, password: String) async throws {
        userState = .loggedIn
        sessionState = .online
    }

    public func logout() async throws {
        userState = .notLoggedIn
        sessionState = .offline
        shopkeeper = nil
    }

    public func updateShopkeeper(shopkeeper: Shopkeeper?) throws {
        self.shopkeeper = shopkeeper
    }

    public func updateConfirmedPrivacyVersion() async throws {
        if shouldThrowPrivacyError {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Privacy update failed"])
        }
        shouldUpdatePrivacy = false
    }

    public func updateConfirmedTermsVersion() async throws {
        if shouldThrowTermsError {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Terms update failed"])
        }
        shouldUpdateTerms = false
    }
}
