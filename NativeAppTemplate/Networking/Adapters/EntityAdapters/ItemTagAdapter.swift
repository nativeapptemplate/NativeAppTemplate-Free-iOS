//
//  ItemTagAdapter.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/01.
//

import struct Foundation.URL

struct ItemTagAdapter: EntityAdapter {
  static func process(resource: JSONAPIResource, relationships: [EntityRelationship] = [], cacheUpdate: DataCacheUpdate = DataCacheUpdate()) throws -> ItemTag {
    guard resource.entityType == .itemTag else { throw EntityAdapterError.invalidResourceTypeForAdapter }
    
    guard let shopId = resource.attributes["shop_id"] as? String,
          let queueNumber = resource.attributes["queue_number"] as? String,
          let state = resource.attributes["state"] as? String,
          let scanState = resource.attributes["scan_state"] as? String,
          let createdAtString = resource.attributes["created_at"] as? String,
          let shopName = resource.attributes["shop_name"] as? String
      else {
        throw EntityAdapterError.invalidOrMissingAttributes
    }

    let createdAt = createdAtString.iso8601!

    let customerReadAtString = resource.attributes["customer_read_at"] as? String
    let customerReadAt = customerReadAtString?.iso8601
    
    let completedAtString = resource.attributes["completed_at"] as? String
    let completedAt = completedAtString?.iso8601

    let alreadyCompleted = resource.attributes["already_completed"] as? Bool

    return ItemTag(
      id: resource.id,
      shopId: shopId,
      queueNumber: queueNumber,
      state: ItemTagState(string: state),
      scanState: ScanState(string: scanState),
      createdAt: createdAt,
      customerReadAt: customerReadAt,
      completedAt: completedAt,
      shopName: shopName,
      alreadyCompleted: alreadyCompleted
    )
  }
}
