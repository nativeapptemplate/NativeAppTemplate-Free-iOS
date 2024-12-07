//
//  ShopkeeperAdapter.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2021/01/16.
//

import Foundation

struct ShopkeeperAdapter: EntityAdapter {
  static func process(resource: JSONAPIResource, relationships: [EntityRelationship] = [], cacheUpdate: DataCacheUpdate = DataCacheUpdate()) throws -> Shopkeeper {
    guard resource.entityType == .shopkeeper else {
      throw EntityAdapterError.invalidResourceTypeForAdapter
    }

    guard let email = resource.attributes["email"] as? String,
      let name = resource.attributes["name"] as? String,
      let timeZone = resource.attributes["time_zone"] as? String
     else {
        throw EntityAdapterError.invalidOrMissingAttributes
    }
    
    return Shopkeeper(
      id: resource.id,
      accountId: "",
      personalAccountId: "",
      accountOwnerId: "",
      accountName: "",
      email: email,
      name: name,
      timeZone: timeZone,
      uid: "",
      token: "",
      client: "",
      expiry: ""
    )!
  }
}
