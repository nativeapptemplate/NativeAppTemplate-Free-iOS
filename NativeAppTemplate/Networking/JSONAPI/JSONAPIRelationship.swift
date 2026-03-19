//
//  JSONAPIRelationship.swift
//  NativeAppTemplate
//

import struct Foundation.URL
import SwiftyJSON

public class JSONAPIRelationship {
    // MARK: - Properties

    var meta: [String: Any] = [:]
    var data: [JSONAPIResource] = []
    var links: [String: URL] = [:]
    var type: String = ""

    // MARK: - Initializers

    convenience init(
        _ json: JSON,
        type: String,
        parent: JSONAPIDocument?
    ) {
        self.init()

        self.type = type
        meta = json["meta"].dictionaryObject ?? [:]
        data = json["data"].arrayValue.map {
            JSONAPIResource($0, parent: nil)
        }

        let nonArrayJSON = json["data"]
        let nonArrayJSONAPIResource = JSONAPIResource(nonArrayJSON, parent: nil)
        data.append(nonArrayJSONAPIResource)
    }
}
