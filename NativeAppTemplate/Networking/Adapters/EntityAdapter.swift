//
//  EntityAdapter.swift
//  NativeAppTemplate
//

import Foundation

protocol EntityAdapter {
    associatedtype Response

    static func process(
        resource: JSONAPIResource,
        relationships: [EntityRelationship],
        cacheUpdate: DataCacheUpdate
    ) throws -> Response
}

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

struct EntityIdentity: Identifiable {
    let id: String
    let type: EntityType
}

struct EntityRelationship {
    let name: String
    let from: EntityIdentity
    let to: EntityIdentity
}

enum EntityAdapterError: Error {
    case invalidResourceTypeForAdapter
    case invalidOrMissingAttributes
    case invalidOrMissingRelationships
}

extension EntityAdapterError: LocalizedError {
    var errorDescription: String? {
        let prefix = "EntityAdapterError::"
        switch self {
        case .invalidResourceTypeForAdapter:
            return "\(prefix)InvalidResourceTypeForAdapter"
        case .invalidOrMissingAttributes:
            return "\(prefix)InvalidOrMissingAttributes"
        case .invalidOrMissingRelationships:
            return "\(prefix)InvalidOrMissingRelationships"
        }
    }
}
