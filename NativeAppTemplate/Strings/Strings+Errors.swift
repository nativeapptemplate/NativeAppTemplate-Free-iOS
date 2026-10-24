//
//  Strings+Errors.swift
//  NativeAppTemplate
//

import Foundation

extension Strings {
    // MARK: Errors

    /// A request failed and the API sent no error_message (e.g. a 5xx without a JSON body)
    static let serverCommunicationError =
        String(localized: "Something went wrong while communicating with the server. Please try again later.")
    /// What the user sees for a developer-only error (a malformed response, a Keychain
    /// failure, ...); its details go to the log
    static let unexpectedError = String(localized: "An unexpected error occurred.")
}
