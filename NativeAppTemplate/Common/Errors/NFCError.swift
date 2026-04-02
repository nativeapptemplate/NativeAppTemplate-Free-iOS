//
//  NFCError.swift
//  NativeAppTemplate
//

import Foundation

enum NFCError: CodedError {
    case scanFailed(String)

    var errorCode: String {
        switch self {
        case .scanFailed:
            "NATI-3001"
        }
    }

    var errorDescription: String? {
        switch self {
        case let .scanFailed(message):
            message
        }
    }
}
