//
//  MeRequest.swift
//  NativeAppTemplate
//

import Foundation

struct UpdateConfirmedPrivacyVersionRequest: Request {
    typealias Response = Void

    // MARK: - Properties

    var method: HTTPMethod {
        .PATCH
    }

    var path: String {
        "/shopkeeper/me/update_confirmed_privacy_version"
    }

    var additionalHeaders: [String: String] = [:]
    var body: Data? {
        nil
    }

    // MARK: - Internal

    func handle(response: Data) throws {}
}

struct UpdateConfirmedTermsVersionRequest: Request {
    typealias Response = Void

    // MARK: - Properties

    var method: HTTPMethod {
        .PATCH
    }

    var path: String {
        "/shopkeeper/me/update_confirmed_terms_version"
    }

    var additionalHeaders: [String: String] = [:]
    var body: Data? {
        nil
    }

    // MARK: - Internal

    func handle(response: Data) throws {}
}
