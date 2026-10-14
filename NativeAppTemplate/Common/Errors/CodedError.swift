//
//  CodedError.swift
//  NativeAppTemplate
//

// Error codes share the `NATIVEAPPTEMPLATE-XXXX` prefix across iOS and Android.
// Ranges:
//   1xxx App errors
//   2xxx API errors (NativeAppTemplateAPIError, EntityAdapterError)
//   4xxx Persistence/Keychain errors (KeychainStoreError)

import Foundation

/// `errorDescription` is what the user sees, so it is localized; developer details
/// (status codes, field names, underlying errors) go to `debugDescription`, which is
/// for the log only.
protocol CodedError: LocalizedError, Sendable {
    var errorCode: String { get }

    /// The error with its developer details, for the log only
    var debugDescription: String { get }
}

extension CodedError {
    var formattedDescription: String {
        "[\(errorCode)] \(errorDescription ?? "Unknown error")"
    }

    /// Errors without developer details log what the user sees
    var debugDescription: String {
        formattedDescription
    }
}

extension Error {
    var codedDescription: String {
        (self as? CodedError)?.formattedDescription ?? localizedDescription
    }

    /// Returns `debugDescription` if the error conforms to `CodedError`, otherwise
    /// falls back to `localizedDescription`. For the log, not for the user.
    var debugCodedDescription: String {
        (self as? CodedError)?.debugDescription ?? localizedDescription
    }
}
