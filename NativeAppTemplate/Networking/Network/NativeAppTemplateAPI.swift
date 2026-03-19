//
//  NativeAppTemplateAPI.swift
//  NativeAppTemplate
//

import Foundation
import Observation

typealias HTTPHeaders = [String: String]
typealias HTTPHeader = HTTPHeaders.Element

enum NativeAppTemplateAPIError: Error {
    case requestFailed(Error?, Int, String?)
    case processingError(Error?)
    case responseMissingRequiredMeta(field: String?)
    case responseHasIncorrectNumberOfElements
    case noData
}

extension NativeAppTemplateAPIError: LocalizedError {
    var errorDescription: String? {
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

@MainActor
public struct NativeAppTemplateAPI: Equatable {
    public nonisolated static func == (lhs: NativeAppTemplateAPI, rhs: NativeAppTemplateAPI) -> Bool {
        lhs.environment == rhs.environment &&
            lhs.session == rhs.session &&
            lhs.authToken == rhs.authToken &&
            lhs.client == rhs.client &&
            lhs.expiry == rhs.expiry &&
            lhs.uid == rhs.uid &&
            lhs.accountId == rhs.accountId
    }

    // MARK: - Properties

    let environment: NativeAppTemplateEnvironment
    let session: URLSession
    let authToken: String
    let client: String
    let expiry: String
    let uid: String
    let accountId: String

    // MARK: - HTTP Headers

    let contentTypeHeader: HTTPHeader = ("Content-Type", "application/vnd.api+json; charset=utf-8")
    var additionalHeaders: HTTPHeaders = [:]

    nonisolated init() {
        self.init(authToken: "", client: "", expiry: "", uid: "", accountId: "")
    }

    // MARK: - Initializers

    nonisolated init(
        session: URLSession = .init(configuration: .default),
        environment: NativeAppTemplateEnvironment = .prod,
        authToken: String,
        client: String,
        expiry: String,
        uid: String,
        accountId: String
    ) {
        self.session = session
        self.environment = environment
        self.authToken = authToken
        self.client = client
        self.expiry = expiry
        self.uid = uid
        self.accountId = accountId
    }
}
