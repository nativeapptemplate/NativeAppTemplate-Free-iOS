//
//  NativeAppTemplateAPIError.swift
//  NativeAppTemplate
//

import Foundation

enum NativeAppTemplateAPIError: CodedError {
    case requestFailed(Error?, Int, String?)
    case processingError(Error?)
    case responseMissingRequiredMeta(field: String?)
    case responseHasIncorrectNumberOfElements
    case noData

    nonisolated var errorCode: String {
        switch self {
        case .requestFailed:
            "NATIVEAPPTEMPLATE-2001"
        case .processingError:
            "NATIVEAPPTEMPLATE-2002"
        case .responseMissingRequiredMeta:
            "NATIVEAPPTEMPLATE-2003"
        case .responseHasIncorrectNumberOfElements:
            "NATIVEAPPTEMPLATE-2004"
        case .noData:
            "NATIVEAPPTEMPLATE-2005"
        }
    }

    nonisolated var errorDescription: String? {
        switch self {
        case let .requestFailed(error, statusCode, message):
            if let message {
                "\(message) [Status: \(statusCode)]"
            } else {
                "NativeAppTemplateAPIError::RequestFailed" +
                    "[Status: \(statusCode) | Error: \(error?.localizedDescription ?? "UNKNOWN")]"
            }
        case let .processingError(error):
            "NativeAppTemplateAPIError::ProcessingError[Error: \(error?.localizedDescription ?? "UNKNOWN")]"
        case let .responseMissingRequiredMeta(field: field):
            "NativeAppTemplateAPIError::ResponseMissingRequiredMeta[Field: \(field ?? "UNKNOWN")]"
        case .responseHasIncorrectNumberOfElements:
            "NativeAppTemplateAPIError::ResponseHasIncorrectNumberOfElements"
        case .noData:
            "NativeAppTemplateAPIError::NoData"
        }
    }
}
