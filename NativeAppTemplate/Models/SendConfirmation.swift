//
//  SendConfirmation.swift
//  NativeAppTemplate
//

import Foundation

struct SendConfirmation: Codable {
    var email: String
    var redirectUrl: String = NativeAppTemplateEnvironment.prod.baseURL
        .appendingPathComponent("/shopkeeper_auth/confirmation_result").absoluteString
}

extension SendConfirmation {
    func toJson() -> [String: Any] {
        [
            "email": email,
            "redirect_url": redirectUrl
        ]
    }
}
