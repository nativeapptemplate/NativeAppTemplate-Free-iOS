//
//  ShopAdapter.swift
//  NativeAppTemplate
//

import struct Foundation.URL

enum ShopAdapter {
    static func process(resource: JSONAPIResource) throws -> Shop {
        guard resource.entityType == .shop else { throw EntityAdapterError.invalidResourceTypeForAdapter }

        guard let name = resource.attributes["name"] as? String,
              let timeZone = resource.attributes["time_zone"] as? String
        else {
            throw EntityAdapterError.invalidOrMissingAttributes
        }

        return Shop(
            id: resource.id,
            name: name,
            description: resource.attributes["description"] as? String ?? "",
            timeZone: timeZone,
            itemTagsCount: resource.attributes["item_tags_count"] as? Int ?? 0,
            completedItemTagsCount: resource.attributes["completed_item_tags_count"] as? Int ?? 0
        )
    }
}
