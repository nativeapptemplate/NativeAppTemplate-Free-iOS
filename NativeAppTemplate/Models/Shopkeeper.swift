//
//  Shopkeeper.swift
//  NativeAppTemplate
//

import Foundation

public struct Shopkeeper: Hashable, Codable, Sendable {
    // MARK: - Properties

    var id: String
    var accountId: String
    public var personalAccountId: String
    public var accountOwnerId: String
    public var accountName: String
    public var email: String
    public var name: String
    public var timeZone: String
    /// "en" or "ja": the language the API answers this shopkeeper in
    public var locale: String
    public var uid: String
    public var token: String?
    public var client: String?
    public var expiry: String?

    // MARK: - Initializers

    init?(
        id: String,
        accountId: String,
        personalAccountId: String,
        accountOwnerId: String,
        accountName: String,
        email: String,
        name: String,
        timeZone: String,
        locale: String = Shopkeeper.defaultLocale,
        uid: String,
        token: String,
        client: String,
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
        self.uid = uid
        self.token = token
        self.client = client
        self.expiry = expiry
    }

    init?(dictionary: [String: String]) {
        guard
            let id = dictionary["id"],
            let accountId = dictionary["account_id"],
            let personalAccountId = dictionary["personal_account_id"],
            let accountOwnerId = dictionary["account_owner_id"],
            let accountName = dictionary["account_name"],
            let email = dictionary["email"],
            let name = dictionary["name"],
            let timeZone = dictionary["time_zone"],
            let uid = dictionary["uid"],
            let token = dictionary["token"],
            let client = dictionary["client"],
            let expiry = dictionary["expiry"]
        else {
            return nil
        }

        let locale = dictionary["locale"] ?? Shopkeeper.defaultLocale

        self.id = id
        self.accountId = accountId
        self.personalAccountId = personalAccountId
        self.accountOwnerId = accountOwnerId
        self.accountName = accountName
        self.email = email
        self.name = name
        self.timeZone = timeZone
        self.locale = locale
        self.uid = uid
        self.token = token
        self.client = client
        self.expiry = expiry
    }

    public init(from loggedInShopkeeper: LoggedInShopkeeper) {
        id = loggedInShopkeeper.id
        accountId = loggedInShopkeeper.accountId
        personalAccountId = loggedInShopkeeper.personalAccountId
        accountOwnerId = loggedInShopkeeper.accountOwnerId
        accountName = loggedInShopkeeper.accountName
        email = loggedInShopkeeper.email
        name = loggedInShopkeeper.name
        timeZone = loggedInShopkeeper.timeZone
        locale = loggedInShopkeeper.locale
        token = loggedInShopkeeper.token
        client = loggedInShopkeeper.client
        uid = loggedInShopkeeper.uid
        expiry = loggedInShopkeeper.expiry
    }
}

// MARK: public

public extension Shopkeeper {
    /// The API's column default, for data that predates shopkeepers.locale
    static let defaultLocale = "en"

    /// The languages the API offers, each named in itself
    static let supportedLocales: [(code: String, name: String)] = [
        ("en", "English"),
        ("ja", "日本語")
    ]

    /// The language the app is shown in, as the API names it. The user changes
    /// it in iOS Settings, and shopkeepers.locale follows it so emails match.
    static func appLocale(preferredLocalizations: [String] = Bundle.main.preferredLocalizations) -> String {
        guard let language = preferredLocalizations.first?.split(separator: "-").first.map(String.init),
              supportedLocales.contains(where: { $0.code == language }) else {
            return defaultLocale
        }
        return language
    }

    static func appLocaleName(preferredLocalizations: [String] = Bundle.main.preferredLocalizations) -> String {
        let code = appLocale(preferredLocalizations: preferredLocalizations)
        return supportedLocales.first { $0.code == code }?.name ?? code
    }

    /// The locale to send so the API matches the app, or nil when it already does
    func localeToSync(appLocale: String) -> String? {
        locale == appLocale ? nil : appLocale
    }
}

private extension Shopkeeper {
    private init(
        shopkeeper: Shopkeeper
    ) {
        id = shopkeeper.id
        accountId = shopkeeper.accountId
        personalAccountId = shopkeeper.personalAccountId
        accountOwnerId = shopkeeper.accountOwnerId
        accountName = shopkeeper.accountName
        email = shopkeeper.email
        name = shopkeeper.name
        timeZone = shopkeeper.timeZone
        locale = shopkeeper.locale
        uid = shopkeeper.uid
        token = shopkeeper.token
        client = shopkeeper.client
        expiry = shopkeeper.expiry
    }
}
