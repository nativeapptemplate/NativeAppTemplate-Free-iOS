//
//  SessionRequest.swift
//  NativeAppTemplate
//

import Foundation

struct MakeSessionRequest: Request {
    typealias Response = Shopkeeper

    // MARK: - Properties

    var method: HTTPMethod {
        .POST
    }

    var path: String {
        "/shopkeeper_auth/sign_in"
    }

    var body: Data? {
        let json: [String: Any] = ["email": email, "password": password]
        return try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    }

    // MARK: - Parameters

    let email: String
    let password: String

    func handle(response: Data) throws -> Shopkeeper {
        let json = try JSONSerialization.jsonObject(with: response)
        let doc = JSONAPIDocument(json)
        let shopkeepers = try doc.data.map { try ShopkeeperSignInAdapter.process(resource: $0) }
        guard let shopkeeper = shopkeepers.first else {
            throw NativeAppTemplateAPIError.processingError(nil)
        }
        return shopkeeper
    }
}

struct DestroySessionRequest: Request {
    typealias Response = Void

    // MARK: - Properties

    var method: HTTPMethod {
        .DELETE
    }

    var path: String {
        "/shopkeeper_auth/sign_out"
    }

    var body: Data? {
        nil
    }

    // MARK: - Internal

    func handle(response: Data) throws {}
}
