//
//  EntityAdapter.swift
//  NativeAppTemplate
//

/// The API's resource types (JSON:API `type`) that an adapter turns into a model
enum EntityType {
    case shop
    case shopkeeper
    case shopkeeperSignIn
    case itemTag

    init?(from string: String) {
        switch string {
        case "shop":
            self = .shop
        case "shopkeeper":
            self = .shopkeeper
        case "shopkeeper_sign_in":
            self = .shopkeeperSignIn
        case "item_tag":
            self = .itemTag
        default:
            return nil
        }
    }
}
