//
//  JSONAPIResource.swift
//  NativeAppTemplate
//

import struct Foundation.URL
import SwiftyJSON

public class JSONAPIResource {
    // MARK: - Properties

    weak var parent: JSONAPIDocument?
    var id: String = "0"
    var type: String = ""
    var relationships: [JSONAPIRelationship] = []
    var attributes: [String: Any] = [:]
    var links: [String: URL] = [:]
    var meta: [String: Any] = [:]
    var entityType: EntityType? {
        EntityType(from: type)
    }

    var entityID: EntityIdentity? {
        guard let entityType else { return nil }

        return EntityIdentity(id: id, type: entityType)
    }

    subscript(key: String) -> Any? {
        attributes[key]
    }

    // MARK: - Initializers

    convenience init(
        _ json: JSON,
        parent: JSONAPIDocument?
    ) {
        self.init()

        if let doc = parent {
            self.parent = doc
        }

        id = json["id"].stringValue
        type = json["type"].stringValue

        for relationship in json["relationships"].dictionaryValue {
            relationships.append(
                JSONAPIRelationship(
                    relationship.value,
                    type: relationship.key,
                    parent: nil
                )
            )
        }

        attributes = json["attributes"].dictionaryObject ?? [:]

        if let linksDict = json["links"].dictionaryObject {
            for link in linksDict {
                if let strValue = link.value as? String,
                   let url = URL(string: strValue) {
                    links[link.key] = url
                }
            }
        }

        meta = json["meta"].dictionaryValue
    }
}

extension JSONAPIResource {
    subscript<T>(key: some CustomStringConvertible) -> T? {
        self[key.description] as? T
    }
}
