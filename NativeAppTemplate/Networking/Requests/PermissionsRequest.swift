//
//  PermissionsRequest.swift
//  NativeAppTemplate
//

import Foundation

struct PermissionsResponse: Sendable {
    var iosAppVersion: Int
    var shouldUpdatePrivacy: Bool
    var shouldUpdateTerms: Bool
    var maximumQueueNumberLength: Int
    var shopLimitCount: Int
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

    var additionalHeaders: [String: String] = [:]
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

        let maximumQueueNumberLength = doc.meta["maximum_queue_number_length"] as? Int ?? 256

        guard let shopLimitCount = doc.meta["shop_limit_count"] as? Int else {
            throw NativeAppTemplateAPIError.responseMissingRequiredMeta(field: "shop_limit_count")
        }

        return PermissionsResponse(
            iosAppVersion: iosAppVersion,
            shouldUpdatePrivacy: shouldUpdatePrivacy,
            shouldUpdateTerms: shouldUpdateTerms,
            maximumQueueNumberLength: maximumQueueNumberLength,
            shopLimitCount: shopLimitCount
        )
    }
}
