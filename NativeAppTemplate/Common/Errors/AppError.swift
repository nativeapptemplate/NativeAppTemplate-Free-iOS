//
//  AppError.swift
//  NativeAppTemplate
//

import Foundation

enum AppError: CodedError {
    case unexpected(
        description: String,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    )

    var errorCode: String {
        switch self {
        case .unexpected:
            "NATI-1001"
        }
    }

    var errorDescription: String? {
        switch self {
        case let .unexpected(description, _, _, _):
            "An unexpected error occurred. \(description)"
        }
    }

    var debugDescription: String {
        switch self {
        case let .unexpected(description, file, line, function):
            "[\(errorCode)] \(description) (file: \(file), line: \(line), function: \(function))"
        }
    }
}
