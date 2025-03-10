//
//  ScanResultError.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/04.
//

import Foundation

enum ScanResultError: Error {
  case failed(String)
}

extension ScanResultError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .failed(let message):
      return message
    }
  }
}
