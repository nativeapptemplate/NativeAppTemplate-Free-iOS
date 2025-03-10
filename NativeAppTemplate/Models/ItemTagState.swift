//
//  ItemTagState.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/01.
//

enum ItemTagState: String, CaseIterable, Identifiable, Codable {
  case idled,
       completed

  var id: Self { self }
  
  init(string: String) {
    switch string {
    case "idled":
      self = .idled
    case "completed":
      self = .completed
    default:
      self = .idled
    }
  }

  var displayString: String {
    switch self {
    case .idled:
      return "Idling"
    case .completed:
      return "Completed"
    }
  }
}
