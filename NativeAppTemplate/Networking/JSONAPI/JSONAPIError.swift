//
//  JSONAPIError.swift
//  NativeAppTemplate
//

import struct Foundation.URL

public class JSONAPIError {
    // MARK: - Properties

    var id: String = ""
    var links: [String: URL] = [:]
    var status: String = ""
    var code: String = ""
    var title: String = ""
    var detail: String = ""
    var source: JSONAPIErrorSource?
    var meta: [String: Any] = [:]

    // MARK: - Initializers

    convenience init(_ json: Any) {
        self.init()

        guard let dict = json as? [String: Any] else { return }

        id = (dict["id"] as? String) ?? ""

        if let linksDict = dict["links"] as? [String: Any] {
            for link in linksDict {
                if let strValue = link.value as? String,
                   let url = URL(string: strValue) {
                    links[link.key] = url
                }
            }
        }

        status = (dict["status"] as? String) ?? ""
        code = (dict["code"] as? String) ?? ""
        title = (dict["title"] as? String) ?? ""
        detail = (dict["detail"] as? String) ?? ""
        source = JSONAPIErrorSource(dict["source"] as Any)
        meta = dict["meta"] as? [String: Any] ?? [:]
    }
}
