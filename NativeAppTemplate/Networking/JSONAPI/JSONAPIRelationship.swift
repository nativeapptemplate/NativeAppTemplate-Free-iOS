//
//  JSONAPIRelationship.swift
//  NativeAppTemplate
//

import struct Foundation.URL

public class JSONAPIRelationship {
    // MARK: - Properties

    var meta: [String: Any] = [:]
    var data: [JSONAPIResource] = []
    var links: [String: URL] = [:]
    var type: String = ""

    // MARK: - Initializers

    convenience init(
        _ json: Any,
        type: String,
        parent: JSONAPIDocument?
    ) {
        self.init()

        guard let dict = json as? [String: Any] else { return }

        self.type = type
        meta = dict["meta"] as? [String: Any] ?? [:]
        data = (dict["data"] as? [[String: Any]] ?? []).map {
            JSONAPIResource($0, parent: nil)
        }

        if let singleData = dict["data"] as? [String: Any] {
            data.append(JSONAPIResource(singleData, parent: nil))
        }
    }
}
