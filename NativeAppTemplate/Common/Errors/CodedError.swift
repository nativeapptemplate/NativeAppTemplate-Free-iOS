//
//  CodedError.swift
//  NativeAppTemplate
//

// Error codes share the `NATIVEAPPTEMPLATE-XXXX` prefix across iOS and Android.
// Ranges: 1xxx App errors, 2xxx API errors.

import Foundation

protocol CodedError: LocalizedError, Sendable {
    var errorCode: String { get }
}

extension CodedError {
    var formattedDescription: String {
        "[\(errorCode)] \(errorDescription ?? "Unknown error")"
    }
}

extension Error {
    var codedDescription: String {
        (self as? CodedError)?.formattedDescription ?? localizedDescription
    }
}
