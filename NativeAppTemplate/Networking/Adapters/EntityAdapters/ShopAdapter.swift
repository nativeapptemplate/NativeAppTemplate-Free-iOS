//
//  ShopAdapter.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2022/06/28.
//

import struct Foundation.URL

struct ShopAdapter: EntityAdapter {
  static func process(resource: JSONAPIResource, relationships: [EntityRelationship] = [], cacheUpdate: DataCacheUpdate = DataCacheUpdate()) throws -> Shop {
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
      timeZone: timeZone
   )
  }
}
