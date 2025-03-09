//
//  ScanState.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/01.
//

enum ScanState: String, Identifiable, CaseIterable, Codable {
  case unscanned,
       scanned

  var id: Self { self }
    
  init(string: String) {
    switch string {
    case "unscanned":
      self = .unscanned
    case "scanned":
      self = .scanned
    default:
      self = .unscanned
    }
  }
  
  func toJson() -> String {
    switch self {
    case .unscanned:
      return "unscanned"
    case .scanned:
      return "scanned"
    }
  }
  
  var displayString: String {
    switch self {
    case .unscanned:
      return "Unscanned"
    case .scanned:
      return "Scanned"
    }
  }
}
