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

    /// What the user sees: the API's error_message (already localized) as is, else a
    /// localized generic text. The status and other developer details are in
    /// `debugDescription`, for the log.
    nonisolated var errorDescription: String? {
        switch self {
        case let .requestFailed(_, _, message):
            message ?? Strings.serverCommunicationError
        case .processingError, .responseMissingRequiredMeta, .responseHasIncorrectNumberOfElements, .noData:
            Strings.unexpectedError
        }
    }

    nonisolated var debugDescription: String {
        "[\(errorCode)] \(detail)"
    }

    private nonisolated var detail: String {
        switch self {
        case let .requestFailed(error, statusCode, message):
            "NativeAppTemplateAPIError::RequestFailed[Status: \(statusCode)"
                + " | Message: \(message ?? "NONE")"
                + " | Error: \(error?.localizedDescription ?? "UNKNOWN")]"
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
