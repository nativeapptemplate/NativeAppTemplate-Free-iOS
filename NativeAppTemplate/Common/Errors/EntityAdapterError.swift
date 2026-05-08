//
//  EntityAdapterError.swift
//  NativeAppTemplate
//

import Foundation

/// JSON:API response parsing errors
/// Error codes: NATIVEAPPTEMPLATE-2006 to NATIVEAPPTEMPLATE-2008
enum EntityAdapterError: CodedError {
    case invalidResourceTypeForAdapter
    case invalidOrMissingAttributes
    case invalidOrMissingRelationships

    nonisolated var errorCode: String {
        switch self {
        case .invalidResourceTypeForAdapter:
            "NATIVEAPPTEMPLATE-2006"
        case .invalidOrMissingAttributes:
            "NATIVEAPPTEMPLATE-2007"
        case .invalidOrMissingRelationships:
            "NATIVEAPPTEMPLATE-2008"
        }
    }

    nonisolated var errorDescription: String? {
        let prefix = "EntityAdapterError::"
        switch self {
        case .invalidResourceTypeForAdapter:
            return "\(prefix)InvalidResourceTypeForAdapter"
        case .invalidOrMissingAttributes:
            return "\(prefix)InvalidOrMissingAttributes"
        case .invalidOrMissingRelationships:
            return "\(prefix)InvalidOrMissingRelationships"
        }
    }
}
