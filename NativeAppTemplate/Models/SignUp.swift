//
//  SignUp.swift
//  NativeAppTemplate
//

import Foundation

struct SignUp: Codable {
    var name: String
    var email: String
    var timeZone: String
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
            "password": password!
        ]
    }

    func toJsonForUpdate() -> [String: Any] {
        [
            "name": name,
            "email": email,
            "time_zone": timeZone
        ]
    }
}
