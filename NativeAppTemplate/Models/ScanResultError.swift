//
//  ScanResultError.swift
//  NativeAppTemplate
//

import Foundation

enum ScanResultError: Error {
    case failed(String)
}

extension ScanResultError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .failed(message):
            message
        }
    }
}
