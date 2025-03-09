//
//  CompleteScanResult.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import Foundation

enum CompleteScanResultType {
  case idled
  case completed
  case reset
  case failed
  
  var displayString: String {
    switch self {
    case .idled:
      return "Idling"
    case .completed:
      return "Completed!"
    case .reset:
      return "Reset!"
    case .failed:
      return "Failed"
    }
  }
}

struct CompleteScanResult {
  var itemTag: ItemTag?
  var type: CompleteScanResultType = .idled
  var message = ""
  var scannedAt = Date.now
}
