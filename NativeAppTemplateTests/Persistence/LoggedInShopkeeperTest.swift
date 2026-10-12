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

/// Writes every key LoggedInShopkeeper.encode(with:) writes except one, as a
/// damaged or partly written Keychain item would hold
@objc(PartialLoggedInShopkeeper)
final class PartialLoggedInShopkeeper: NSObject, NSSecureCoding {
    static let supportsSecureCoding = true

    /// The string keys LoggedInShopkeeper.encode(with:) writes (CodingKeys)
    static let stringKeys = [
        "id", "accountId", "personalAccountId", "accountOwnerId", "accountName",
        "email", "name", "timeZone", "locale", "token", "client", "uid", "expiry"
    ]

    let missingKey: String

    init(missingKey: String) {
        self.missingKey = missingKey
    }

    required init?(coder _: NSCoder) {
        missingKey = ""
    }

    func encode(with coder: NSCoder) {
        for key in Self.stringKeys where key != missingKey {
            coder.encode("\(key)-value" as NSString, forKey: key)
        }
        coder.encode(["read_data"] as NSArray, forKey: "permissions")
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

    private func decode(_ object: NSObject, as className: String) throws -> LoggedInShopkeeper? {
        let archived = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: true)
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: archived)
        unarchiver.setClass(LoggedInShopkeeper.self, forClassName: className)
        return unarchiver.decodeObject(of: LoggedInShopkeeper.self, forKey: NSKeyedArchiveRootObjectKey)
    }

    /// A Keychain item missing a required field must decode as nil, so
    /// KeychainStore.retrieve() throws and LoginRepository treats the user as
    /// signed out, instead of crashing the app on every launch.
    /// `locale` is left out: it is optional (see archiveWithoutLocaleDecodesAsEnglish).
    @Test(arguments: PartialLoggedInShopkeeper.stringKeys.filter { $0 != "locale" })
    func archiveMissingRequiredFieldDecodesAsNil(missingKey: String) throws {
        let restored = try decode(PartialLoggedInShopkeeper(missingKey: missingKey), as: "PartialLoggedInShopkeeper")
        #expect(restored == nil)
    }

    /// Guards the test above: with nothing missing the same archive decodes
    @Test
    func completePartialArchiveDecodes() throws {
        let restored = try #require(try decode(
            PartialLoggedInShopkeeper(missingKey: ""),
            as: "PartialLoggedInShopkeeper"
        ))
        #expect(restored.token == "token-value")
        #expect(restored.locale == "locale-value")
    }
}
