//
//  SendResetPassword.swift
//  NativeAppTemplate
//

import Foundation

struct SendResetPassword: Codable {
    var email: String
    var redirectUrl: String = NativeAppTemplateEnvironment.prod.baseURL
        .appendingPathComponent("/shopkeeper_auth/reset_password/edit").absoluteString
}

extension SendResetPassword {
    func toJson() -> [String: Any] {
        [
            "email": email,
            "redirect_url": redirectUrl
        ]
    }
}
