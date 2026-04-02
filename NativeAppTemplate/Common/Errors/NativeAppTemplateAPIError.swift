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
            "NATI-2001"
        case .processingError:
            "NATI-2002"
        case .responseMissingRequiredMeta:
            "NATI-2003"
        case .responseHasIncorrectNumberOfElements:
            "NATI-2004"
        case .noData:
            "NATI-2005"
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
