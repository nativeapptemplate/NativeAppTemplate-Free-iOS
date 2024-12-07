//
//  UpdatePassword.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/25.
//

import Foundation

struct UpdatePassword: Codable {
  var currentPassword: String
  var password: String
  var passwordConfirmation: String
}

extension UpdatePassword {
  func toJson() -> [String: Any] {
    [ "shopkeeper":
      [
        "current_password": currentPassword,
        "password": password,
        "password_confirmation": passwordConfirmation
      ]
    ]
  }
}
