//
//  ShopkeeperSignInAdapter.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2022/08/11.
//

import Foundation

struct ShopkeeperSignInAdapter: EntityAdapter {
  static func process(resource: JSONAPIResource, relationships: [EntityRelationship] = [], cacheUpdate: DataCacheUpdate = DataCacheUpdate()) throws -> Shopkeeper {
    guard resource.entityType == .shopkeeperSignIn else {
      throw EntityAdapterError.invalidResourceTypeForAdapter
    }

    guard let accountId = resource.attributes["account_id"] as? String,
      let personalAccountId = resource.attributes["personal_account_id"] as? String,
      let accountOwnerId = resource.attributes["account_owner_id"] as? String,
      let accountName = resource.attributes["account_name"] as? String,
      let email = resource.attributes["email"] as? String,
      let name = resource.attributes["name"] as? String,
      let timeZone = resource.attributes["time_zone"] as? String,
      let uid = resource.attributes["uid"] as? String
      else {
        throw EntityAdapterError.invalidOrMissingAttributes
    }
    
    return Shopkeeper(
      id: resource.id,
      accountId: accountId,
      personalAccountId: personalAccountId,
      accountOwnerId: accountOwnerId,
      accountName: accountName,
      email: email,
      name: name,
      timeZone: timeZone,
      uid: uid,
      token: resource.attributes["token"] as? String ?? "",
      client: resource.attributes["client"] as? String ?? "",
      expiry: resource.attributes["expiry"] as? String ?? ""
    )!
  }
}
