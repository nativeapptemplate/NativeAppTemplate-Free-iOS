//
//  JSONAPIResource.swift
//  NativeAppTemplate
//

/// A JSON:API resource object, reduced to what the adapters read
struct JSONAPIResource {
    // MARK: - Properties

    /// "" when missing
    let id: String
    /// "" when missing, which matches no EntityType
    let type: String
    let attributes: [String: Any]

    var entityType: EntityType? {
        EntityType(from: type)
    }

    // MARK: - Initializers

    init(_ dict: [String: Any]) {
        id = dict["id"] as? String ?? ""
        type = dict["type"] as? String ?? ""
        attributes = dict["attributes"] as? [String: Any] ?? [:]
    }
}
