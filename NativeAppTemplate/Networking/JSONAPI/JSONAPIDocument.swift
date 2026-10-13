//
//  JSONAPIDocument.swift
//  NativeAppTemplate
//

/// A JSON:API document (https://jsonapi.org/format/#document-structure), reduced to
/// what the requests read: `data`, `included` and the top-level `meta`.
/// Anything but a JSON object reads as an empty document.
struct JSONAPIDocument {
    // MARK: - Properties

    let meta: [String: Any]
    let data: [JSONAPIResource]
    let included: [JSONAPIResource]

    // MARK: - Initializers

    init(_ json: Any) {
        let dict = json as? [String: Any] ?? [:]

        meta = dict["meta"] as? [String: Any] ?? [:]
        data = Self.resources(dict["data"])
        included = Self.resources(dict["included"])
    }

    /// `data` is an object for one resource and an array for a collection;
    /// `included` is read the same way
    private static func resources(_ json: Any?) -> [JSONAPIResource] {
        if let array = json as? [[String: Any]] {
            return array.map(JSONAPIResource.init)
        }
        if let object = json as? [String: Any] {
            return [JSONAPIResource(object)]
        }
        return []
    }
}
