//
//  KeychainStoreError.swift
//  NativeAppTemplate
//

import Foundation

/// Keychain persistence errors
/// Error codes: NATIVEAPPTEMPLATE-4001 to NATIVEAPPTEMPLATE-4004
enum KeychainStoreError: CodedError {
    case secCallFailed(Error)
    case notFound
    case badData
    case archiveFailure(Error)

    nonisolated var errorCode: String {
        switch self {
        case .secCallFailed:
            "NATIVEAPPTEMPLATE-4001"
        case .notFound:
            "NATIVEAPPTEMPLATE-4002"
        case .badData:
            "NATIVEAPPTEMPLATE-4003"
        case .archiveFailure:
            "NATIVEAPPTEMPLATE-4004"
        }
    }

    nonisolated var errorDescription: String? {
        switch self {
        case let .secCallFailed(error):
            "KeychainStoreError::SecCallFailed[Error: \(error.localizedDescription)]"
        case .notFound:
            "KeychainStoreError::NotFound"
        case .badData:
            "KeychainStoreError::BadData"
        case let .archiveFailure(error):
            "KeychainStoreError::ArchiveFailure[Error: \(error.localizedDescription)]"
        }
    }
}
