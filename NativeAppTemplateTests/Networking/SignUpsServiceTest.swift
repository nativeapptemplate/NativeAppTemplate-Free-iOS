//
//  SignUpsServiceTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@MainActor
@Suite
struct SignUpsServiceTest {
    let client = NativeAppTemplateAPI(
        authToken: "token",
        client: "client",
        expiry: "expiry",
        uid: "uid",
        accountId: "account-id"
    )

    /// devise_token_auth's routes sit at the root, without the account and
    /// /api/v1 prefix that Service adds (SessionController syncs the locale)
    @Test
    func updateLocaleRequestPatchesShopkeeperAuthWithOnlyTheLocale() throws {
        let urlRequest = try SignUpsService(networkClient: client).prepare(request: UpdateLocaleRequest(locale: "ja"))

        #expect(urlRequest.url == client.environment.baseURL.appendingPathComponent("/shopkeeper_auth"))
        #expect(urlRequest.httpMethod == "PATCH")
        let body = try #require(urlRequest.httpBody)
        #expect(try JSONSerialization.jsonObject(with: body) as? [String: String] == ["locale": "ja"])
        #expect(urlRequest.value(forHTTPHeaderField: "access-token") == "token")
    }
}
