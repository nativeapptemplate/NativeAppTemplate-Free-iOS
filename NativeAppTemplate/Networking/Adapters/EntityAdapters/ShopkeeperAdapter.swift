//
//  ShopkeeperAdapter.swift
//  NativeAppTemplate
//

import Foundation

enum ShopkeeperAdapter {
    static func process(resource: JSONAPIResource) throws -> Shopkeeper {
        guard resource.entityType == .shopkeeper else {
            throw EntityAdapterError.invalidResourceTypeForAdapter
        }

        guard let email = resource.attributes["email"] as? String,
              let name = resource.attributes["name"] as? String,
              let timeZone = resource.attributes["time_zone"] as? String
        else {
            throw EntityAdapterError.invalidOrMissingAttributes
        }

        return Shopkeeper(
            id: resource.id,
            accountId: "",
            personalAccountId: "",
            accountOwnerId: "",
            accountName: "",
            email: email,
            name: name,
            timeZone: timeZone,
            locale: resource.attributes["locale"] as? String ?? Shopkeeper.defaultLocale,
            uid: "",
            token: "",
            client: "",
            expiry: ""
        )!
    }
}
