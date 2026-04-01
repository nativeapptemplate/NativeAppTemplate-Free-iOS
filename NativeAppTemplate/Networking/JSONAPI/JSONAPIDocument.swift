//
//  JSONAPIDocument.swift
//  NativeAppTemplate
//

import struct Foundation.URL

class JSONAPIDocument {
    // MARK: - Properties

    var meta: [String: Any] = [:]
    var included: [JSONAPIResource] = []
    var data: [JSONAPIResource] = []
    var errors: [JSONAPIError] = []
    var links: [String: URL] = [:]

    // MARK: - Initializers

    convenience init(_ json: Any) {
        self.init()

        guard let dict = json as? [String: Any] else { return }

        meta = dict["meta"] as? [String: Any] ?? [:]
        errors = (dict["error"] as? [[String: Any]] ?? []).map { JSONAPIError($0) }

        if let dataArray = dict["data"] as? [[String: Any]] {
            data = dataArray.map { JSONAPIResource($0, parent: self) }
        } else if let dataDict = dict["data"] as? [String: Any] {
            data = [JSONAPIResource(dataDict, parent: self)]
        }

        if let includedArray = dict["included"] as? [[String: Any]] {
            included = includedArray.map { JSONAPIResource($0, parent: self) }
        } else if let includedDict = dict["included"] as? [String: Any] {
            included = [JSONAPIResource(includedDict, parent: self)]
        }

        if let linksDict = dict["links"] as? [String: Any] {
            for link in linksDict {
                if let strValue = link.value as? String,
                   let url = URL(string: strValue) {
                    links[link.key] = url
                }
            }
        }
    }
}
