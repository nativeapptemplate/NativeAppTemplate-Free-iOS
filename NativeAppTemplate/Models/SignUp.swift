//
//  SignUp.swift
//  NativeAppTemplate
//

import Foundation

struct SignUp: Codable {
    var name: String
    var email: String
    var timeZone: String
    /// The language the app is shown in, so emails match the app
    var locale: String = Shopkeeper.appLocale()
    var currentPlatform: String = "ios"
    var password: String?
}

extension SignUp {
    func toJsonForCreate() -> [String: Any] {
        [
            "name": name,
            "email": email,
            "time_zone": timeZone,
            "current_platform": currentPlatform,
            "locale": locale,
            "password": password!
        ]
    }

    func toJsonForUpdate() -> [String: Any] {
        [
            "name": name,
            "email": email,
            "time_zone": timeZone,
            "locale": locale
        ]
    }
}
