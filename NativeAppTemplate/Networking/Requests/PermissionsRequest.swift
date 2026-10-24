//
//  PermissionsRequest.swift
//  NativeAppTemplate
//

import Foundation

struct PermissionsResponse: Sendable {
    var iosAppVersion: Int
    var shouldUpdatePrivacy: Bool
    var shouldUpdateTerms: Bool
}

struct PermissionsRequest: Request {
    typealias Response = PermissionsResponse

    // MARK: - Properties

    var method: HTTPMethod {
        .GET
    }

    var path: String {
        "/shopkeeper/permissions"
    }

    var body: Data? {
        nil
    }

    // MARK: - Internal

    func handle(response: Data) throws -> Response {
        let json = try JSONSerialization.jsonObject(with: response)
        let doc = JSONAPIDocument(json)

        guard let iosAppVersion = doc.meta["ios_app_version"] as? Int else {
            throw NativeAppTemplateAPIError.responseMissingRequiredMeta(field: "ios_app_version")
        }

        guard let shouldUpdatePrivacy = doc.meta["should_update_privacy"] as? Bool else {
            throw NativeAppTemplateAPIError.responseMissingRequiredMeta(field: "should_update_privacy")
        }

        guard let shouldUpdateTerms = doc.meta["should_update_terms"] as? Bool else {
            throw NativeAppTemplateAPIError.responseMissingRequiredMeta(field: "should_update_terms")
        }

        // shop_limit_count in the meta is not read: the shop list's meta carries the limit
        // the app shows

        return PermissionsResponse(
            iosAppVersion: iosAppVersion,
            shouldUpdatePrivacy: shouldUpdatePrivacy,
            shouldUpdateTerms: shouldUpdateTerms
        )
    }
}
