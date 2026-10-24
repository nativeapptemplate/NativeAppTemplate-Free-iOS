//
//  PermissionsRequestTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// The permissions response's meta decides what MainView shows after sign-in:
/// should_update_privacy and should_update_terms put the accept-privacy and
/// accept-terms screens in front of the tabs (SessionController.fetchPermissions
/// copies them to shouldUpdatePrivacy / shouldUpdateTerms).
struct PermissionsRequestTest {
    /// The meta keys PermissionsRequest.handle requires, as the API sends them
    private static func meta(shouldUpdatePrivacy: Bool = false, shouldUpdateTerms: Bool = false) -> [String: Any] {
        [
            "ios_app_version": 21,
            "should_update_privacy": shouldUpdatePrivacy,
            "should_update_terms": shouldUpdateTerms
        ]
    }

    private func handle(meta: [String: Any], data: [[String: Any]] = []) throws -> PermissionsResponse {
        let body = try JSONSerialization.data(withJSONObject: ["data": data, "meta": meta])
        return try PermissionsRequest().handle(response: body)
    }

    @Test(arguments: [(false, false), (true, false), (false, true), (true, true)])
    func privacyAndTermsFlagsComeFromTheMeta(privacy: Bool, terms: Bool) throws {
        let response = try handle(meta: Self.meta(shouldUpdatePrivacy: privacy, shouldUpdateTerms: terms))

        #expect(response.shouldUpdatePrivacy == privacy)
        #expect(response.shouldUpdateTerms == terms)
    }

    /// The API also sends shop_limit_count, but the app reads the limit from the shop
    /// list's meta; it only stood in as the "permissions loaded" mark, which is
    /// SessionController.didFetchPermissions now. Requiring it failed every permissions
    /// load in an app whose API dropped it
    @Test
    func limitCountIsNotRequired() throws {
        let response = try handle(meta: Self.meta())

        // The value in meta() above, which has no limit count
        #expect(response.iosAppVersion == 21)
    }

    /// A response without a flag must not quietly skip the privacy or terms
    /// screen: it is an error naming the missing field (NATIVEAPPTEMPLATE-2003)
    @Test(arguments: [
        "ios_app_version",
        "should_update_privacy",
        "should_update_terms"
    ])
    func missingMetaFieldThrowsNamingIt(field: String) throws {
        var meta = Self.meta()
        meta.removeValue(forKey: field)

        #expect {
            try handle(meta: meta)
        } throws: { error in
            guard case let .responseMissingRequiredMeta(field: missing) = error as? NativeAppTemplateAPIError else {
                return false
            }
            return missing == field
        }
    }

    /// A flag of the wrong type is as good as missing
    @Test
    func flagOfTheWrongTypeThrows() throws {
        var meta = Self.meta()
        meta["should_update_terms"] = "yes"

        #expect(throws: NativeAppTemplateAPIError.self) {
            try handle(meta: meta)
        }
    }
}
