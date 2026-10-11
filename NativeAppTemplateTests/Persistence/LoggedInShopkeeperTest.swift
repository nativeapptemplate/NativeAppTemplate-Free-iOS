//
//  LoggedInShopkeeperTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// Writes the keys an app version without `locale` archived, under its own
/// class name, so the test can decode it as `LoggedInShopkeeper`.
@objc(LegacyLoggedInShopkeeper)
final class LegacyLoggedInShopkeeper: NSObject, NSSecureCoding {
    static let supportsSecureCoding = true

    override init() {}

    required init?(coder _: NSCoder) {}

    func encode(with coder: NSCoder) {
        for key in [
            "id", "accountId", "personalAccountId", "accountOwnerId", "accountName",
            "email", "name", "timeZone", "token", "client", "uid", "expiry"
        ] {
            coder.encode("\(key)-value" as NSString, forKey: key)
        }
    }
}

struct LoggedInShopkeeperTest {
    private func shopkeeper(locale: String) -> Shopkeeper {
        Shopkeeper(
            id: "id",
            accountId: "account",
            personalAccountId: "personal",
            accountOwnerId: "owner",
            accountName: "Account",
            email: "a@example.com",
            name: "Name",
            timeZone: "Tokyo",
            locale: locale,
            uid: "a@example.com",
            token: "token",
            client: "client",
            expiry: "expiry"
        )!
    }

    @Test
    func localeSurvivesArchiving() throws {
        let archived = try NSKeyedArchiver.archivedData(
            withRootObject: LoggedInShopkeeper(from: shopkeeper(locale: "ja")),
            requiringSecureCoding: true
        )

        let restored = try #require(try NSKeyedUnarchiver.unarchivedObject(
            ofClass: LoggedInShopkeeper.self,
            from: archived
        ))
        #expect(Shopkeeper(from: restored).locale == "ja")
    }

    /// A session saved before `locale` existed must still load; the server's
    /// column default for those shopkeepers is "en"
    @Test
    func archiveWithoutLocaleDecodesAsEnglish() throws {
        let archived = try NSKeyedArchiver.archivedData(
            withRootObject: LegacyLoggedInShopkeeper(),
            requiringSecureCoding: true
        )

        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: archived)
        unarchiver.setClass(
            LoggedInShopkeeper.self,
            forClassName: "LegacyLoggedInShopkeeper"
        )
        let restored = try #require(
            unarchiver.decodeObject(of: LoggedInShopkeeper.self, forKey: NSKeyedArchiveRootObjectKey)
        )

        #expect(restored.locale == "en")
        #expect(restored.name == "name-value")
        #expect(restored.timeZone == "timeZone-value")
    }
}
