//
//  UpdatePassword.swift
//  NativeAppTemplate
//

import Foundation

struct UpdatePassword: Codable {
    var currentPassword: String
    var password: String
    var passwordConfirmation: String
}

extension UpdatePassword {
    func toJson() -> [String: Any] {
        ["shopkeeper":
            [
                "current_password": currentPassword,
                "password": password,
                "password_confirmation": passwordConfirmation
            ]
        ]
    }
}
