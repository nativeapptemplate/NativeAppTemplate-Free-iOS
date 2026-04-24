//
//  ItemTag.swift
//  NativeAppTemplate
//

import Foundation

struct ItemTag: Codable, Hashable, Identifiable, Sendable {
    var id: String = ""
    var shopId: String = ""
    var name: String = ""
    var description: String = ""
    var position: Int?
    var state = ItemTagState.idled
    var createdAt = Date.now
    var completedAt: Date?
    var shopName: String = ""
}

extension ItemTag {
    func scanUrl(itemTagType: ItemTagType) -> URL {
        Utility.scanUrl(itemTagId: id, itemTagType: itemTagType.toJson())
    }

    func toJson() -> [String: Any] {
        ["item_tag":
            [
                "name": name,
                "description": description,
                "position": position as Any
            ]
        ]
    }
}
