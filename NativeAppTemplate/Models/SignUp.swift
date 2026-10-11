//
//  SignUp.swift
//  NativeAppTemplate
//

import Foundation

struct SignUp: Codable {
    var name: String
    var email: String
    var timeZone: String
    /// The device's first preferred language, e.g. "ja-JP". The API reduces it
    /// to a language it offers and falls back to English otherwise.
    var locale: String = Locale.preferredLanguages.first ?? "en"
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
