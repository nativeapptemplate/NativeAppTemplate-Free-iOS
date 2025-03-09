//
//  ItemTagType.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/01.
//

import Foundation

enum ItemTagType: String, CaseIterable, Identifiable, Codable {
  case server
  case customer

  var id: Self { self }

  init(string: String) {
    switch string {
    case "server":
      self = .server
    case "customer":
      self = .customer
    default:
      self = .server
    }
  }

  func toJson() -> String {
    switch self {
    case .server:
      return "server"
    case .customer:
      return "customer"
    }
  }

  var displayString: String {
    switch self {
    case .server:
      return "Server"
    case .customer:
      return "Customer"
    }
  }
}
