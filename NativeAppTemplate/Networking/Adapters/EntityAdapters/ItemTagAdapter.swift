//
//  ItemTagAdapter.swift
//  NativeAppTemplate
//

import struct Foundation.URL

enum ItemTagAdapter {
    static func process(resource: JSONAPIResource) throws -> ItemTag {
        guard resource.entityType == .itemTag else { throw EntityAdapterError.invalidResourceTypeForAdapter }

        guard let shopId = resource.attributes["shop_id"] as? String,
              let name = resource.attributes["name"] as? String,
              let position = resource.attributes["position"] as? Int,
              let state = resource.attributes["state"] as? String,
              let createdAtString = resource.attributes["created_at"] as? String,
              let createdAt = createdAtString.iso8601,
              let shopName = resource.attributes["shop_name"] as? String
        else {
            throw EntityAdapterError.invalidOrMissingAttributes
        }

        let description = resource.attributes["description"] as? String ?? ""

        let completedAtString = resource.attributes["completed_at"] as? String
        let completedAt = completedAtString?.iso8601

        return ItemTag(
            id: resource.id,
            shopId: shopId,
            name: name,
            description: description,
            position: position,
            state: ItemTagState(string: state),
            createdAt: createdAt,
            completedAt: completedAt,
            shopName: shopName
        )
    }
}
