//
//  JSONAPIFixtures.swift
//  NativeAppTemplate
//

import Foundation

/// JSON:API bodies shaped like the API's item tag responses (ItemTagSerializer
/// attributes, the pagination meta GetItemTagsRequest reads)
enum JSONAPIFixtures {
    static func itemTag(
        id: String,
        shopId: String = "shop-1",
        name: String = "A001",
        state: String = "idled"
    ) -> [String: Any] {
        [
            "id": id,
            "type": "item_tag",
            "attributes": [
                "shop_id": shopId,
                "name": name,
                "description": "",
                "position": 1,
                "state": state,
                "created_at": "2026-01-01T00:00:00.000Z",
                "shop_name": "Shop 1"
            ] as [String: Any]
        ]
    }

    static func itemTagPage(
        ids: [String],
        currentPage: Int,
        totalPages: Int,
        totalCount: Int? = nil,
        limit: Int = 20,
        shopId: String = "shop-1"
    ) -> [String: Any] {
        [
            "data": ids.map { itemTag(id: $0, shopId: shopId) },
            "meta": [
                "current_page": currentPage,
                "total_pages": totalPages,
                "total_count": totalCount ?? ids.count,
                "limit": limit
            ]
        ]
    }
}
