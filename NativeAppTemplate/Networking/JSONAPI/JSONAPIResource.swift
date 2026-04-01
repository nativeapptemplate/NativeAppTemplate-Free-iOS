//
//  JSONAPIResource.swift
//  NativeAppTemplate
//

import struct Foundation.URL

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
        _ json: Any,
        parent: JSONAPIDocument?
    ) {
        self.init()

        guard let dict = json as? [String: Any] else { return }

        if let doc = parent {
            self.parent = doc
        }

        id = (dict["id"] as? String) ?? ""
        type = (dict["type"] as? String) ?? ""

        if let rels = dict["relationships"] as? [String: Any] {
            for (key, value) in rels {
                relationships.append(
                    JSONAPIRelationship(
                        value,
                        type: key,
                        parent: nil
                    )
                )
            }
        }

        attributes = dict["attributes"] as? [String: Any] ?? [:]

        if let linksDict = dict["links"] as? [String: Any] {
            for link in linksDict {
                if let strValue = link.value as? String,
                   let url = URL(string: strValue) {
                    links[link.key] = url
                }
            }
        }

        meta = dict["meta"] as? [String: Any] ?? [:]
    }
}

extension JSONAPIResource {
    subscript<T>(key: some CustomStringConvertible) -> T? {
        self[key.description] as? T
    }
}
