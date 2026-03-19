//
//  JSONAPIDocument.swift
//  NativeAppTemplate
//

import struct Foundation.URL
import SwiftyJSON

class JSONAPIDocument {
    // MARK: - Properties

    var meta: [String: Any] = [:]
    var included: [JSONAPIResource] = []
    var data: [JSONAPIResource] = []
    var errors: [JSONAPIError] = []
    var links: [String: URL] = [:]

    // MARK: - Initializers

    convenience init(_ json: JSON) {
        self.init()

        data = json["data"].arrayValue.map { JSONAPIResource($0, parent: self) }
        meta = json["meta"].dictionaryObject ?? [:]
        included = json["included"].arrayValue.map { JSONAPIResource($0, parent: self) }
        errors = json["error"].arrayValue.map { JSONAPIError($0) }

        if let dataArray = json["data"].array {
            data = dataArray.map { JSONAPIResource($0, parent: self) }
        } else {
            data = [JSONAPIResource(json["data"], parent: self)]
        }

        if let includedArray = json["included"].array {
            included = includedArray.map { JSONAPIResource($0, parent: self) }
        } else {
            included = [JSONAPIResource(json["included"], parent: self)]
        }

        if let linksDict = json["links"].dictionaryObject {
            for link in linksDict {
                if let strValue = link.value as? String,
                   let url = URL(string: strValue) {
                    links[link.key] = url
                }
            }
        }

        if let linksDict = json["links"].dictionaryObject {
            for link in linksDict {
                if let strValue = link.value as? String,
                   let url = URL(string: strValue) {
                    links[link.key] = url
                }
            }
        }
    }
}
