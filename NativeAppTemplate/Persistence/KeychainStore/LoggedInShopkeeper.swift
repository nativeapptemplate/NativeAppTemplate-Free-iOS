//
//  LoggedInShopkeeper.swift
//  NativeAppTemplate
//

import Foundation

public class LoggedInShopkeeper: NSObject, NSCoding, NSSecureCoding {
    enum CodingKeys: String, CodingKey {
        case id,
             accountId,
             personalAccountId,
             accountOwnerId,
             accountName,
             email,
             name,
             timeZone,
             locale,
             token,
             client,
             uid,
             expiry
    }

    let id: String
    let accountId: String
    let personalAccountId: String
    let accountOwnerId: String
    let accountName: String
    let email: String
    let name: String
    let timeZone: String
    let locale: String
    let token: String
    let client: String
    let uid: String
    let expiry: String

    init(
        id: String,
        accountId: String,
        personalAccountId: String,
        accountOwnerId: String,
        accountName: String,
        email: String,
        name: String,
        timeZone: String,
        locale: String,
        token: String,
        client: String,
        uid: String,
        expiry: String
    ) {
        self.id = id
        self.accountId = accountId
        self.personalAccountId = personalAccountId
        self.accountOwnerId = accountOwnerId
        self.accountName = accountName
        self.email = email
        self.name = name
        self.timeZone = timeZone
        self.locale = locale
        self.token = token
        self.client = client
        self.uid = uid
        self.expiry = expiry
    }

    public init(from shopkeeper: Shopkeeper) {
        id = shopkeeper.id
        accountId = shopkeeper.accountId
        personalAccountId = shopkeeper.personalAccountId
        accountOwnerId = shopkeeper.accountOwnerId
        accountName = shopkeeper.accountName
        email = shopkeeper.email
        name = shopkeeper.name
        timeZone = shopkeeper.timeZone
        locale = shopkeeper.locale

        token = shopkeeper.token!
        client = shopkeeper.client!
        uid = shopkeeper.uid
        expiry = shopkeeper.expiry!
    }

    public func encode(with coder: NSCoder) {
//    For NSCoding
        coder.encode(id, forKey: CodingKeys.id.rawValue)
        coder.encode(accountId, forKey: CodingKeys.accountId.rawValue)
        coder.encode(personalAccountId, forKey: CodingKeys.personalAccountId.rawValue)
        coder.encode(accountOwnerId, forKey: CodingKeys.accountOwnerId.rawValue)
        coder.encode(accountName, forKey: CodingKeys.accountName.rawValue)
        coder.encode(email, forKey: CodingKeys.email.rawValue)
        coder.encode(name, forKey: CodingKeys.name.rawValue)
        coder.encode(timeZone, forKey: CodingKeys.timeZone.rawValue)
        coder.encode(locale, forKey: CodingKeys.locale.rawValue)
        coder.encode(token, forKey: CodingKeys.token.rawValue)
        coder.encode(client, forKey: CodingKeys.client.rawValue)
        coder.encode(uid, forKey: CodingKeys.uid.rawValue)
        coder.encode(expiry, forKey: CodingKeys.expiry.rawValue)
    }

    public required convenience init?(coder decoder: NSCoder) {
        func string(_ key: CodingKeys) -> String? {
            decoder.decodeObject(of: NSString.self, forKey: key.rawValue) as String?
        }

        // A damaged item is treated as signed out (KeychainStore.retrieve()
        // throws), rather than crashing on every launch
        guard let id = string(.id),
              let accountId = string(.accountId),
              let personalAccountId = string(.personalAccountId),
              let accountOwnerId = string(.accountOwnerId),
              let accountName = string(.accountName),
              let email = string(.email),
              let name = string(.name),
              let timeZone = string(.timeZone),
              let token = string(.token),
              let client = string(.client),
              let uid = string(.uid),
              let expiry = string(.expiry)
        else {
            return nil
        }
        // Sessions saved before locale existed have none
        let locale = string(.locale) ?? Shopkeeper.defaultLocale

        self.init(
            id: id,
            accountId: accountId,
            personalAccountId: personalAccountId,
            accountOwnerId: accountOwnerId,
            accountName: accountName,
            email: email,
            name: name,
            timeZone: timeZone,
            locale: locale,
            token: token,
            client: client,
            uid: uid,
            expiry: expiry
        )
    }

    public static let supportsSecureCoding = true
}
