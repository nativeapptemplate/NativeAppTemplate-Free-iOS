//
//  NativeAppTemplateAPI.swift
//  NativeAppTemplate
//

import Foundation
import Observation

typealias HTTPHeaders = [String: String]
typealias HTTPHeader = HTTPHeaders.Element

@MainActor
public struct NativeAppTemplateAPI: Equatable {
    // MARK: - Properties

    let environment: NativeAppTemplateEnvironment
    let authToken: String
    let client: String
    let expiry: String
    let uid: String
    let accountId: String

    nonisolated init() {
        self.init(authToken: "", client: "", expiry: "", uid: "", accountId: "")
    }

    // MARK: - Initializers

    nonisolated init(
        environment: NativeAppTemplateEnvironment = .prod,
        authToken: String,
        client: String,
        expiry: String,
        uid: String,
        accountId: String
    ) {
        self.environment = environment
        self.authToken = authToken
        self.client = client
        self.expiry = expiry
        self.uid = uid
        self.accountId = accountId
    }
}

// MARK: - HTTP Headers

extension NativeAppTemplateAPI {
    /// The devise_token_auth headers that together are a session, plus the platform
    nonisolated var sessionHeaders: [HTTPHeader] {
        [
            ("access-token", authToken),
            ("token-type", "Bearer"),
            ("client", client),
            ("expiry", expiry),
            ("uid", uid),
            ("source", "ios")
        ]
    }
}
