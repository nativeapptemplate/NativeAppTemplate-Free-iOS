//
//  Shop.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2021/01/24.
//

import Foundation

struct Shop: Codable, Identifiable, Sendable {
  var id: String
  var name: String
  var description: String
  var timeZone: String
}

extension Shop {
  func toJsonForCreate() -> [String: Any] {
    [
      "shop": [
        "name": name,
        "description": description,
        "time_zone": timeZone
      ] as [String: Any]
    ]
  }

  func toJsonForUpdate() -> [String: Any] {
    [
      "shop": [
        "name": name,
        "description": description,
        "time_zone": timeZone
      ] as [String: Any]
    ]
  }
}

extension Shop: Hashable {
  static func == (lhs: Shop, rhs: Shop) -> Bool {
    lhs.id == rhs.id &&
      lhs.name == rhs.name &&
      lhs.description == rhs.description &&
      lhs.timeZone == rhs.timeZone
  }
}
