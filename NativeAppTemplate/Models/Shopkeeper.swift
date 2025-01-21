//
//  Shopkeeper.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2020/04/05.
//  Copyright © 2024 Daisuke Adachi All rights reserved.
//

import Foundation

public struct Shopkeeper: Hashable, Codable, Sendable {

  // MARK: - Properties
  var id: String
  var accountId: String
  public var personalAccountId: String
  public var accountOwnerId: String
  public var accountName: String
  public var email: String
  public var name: String
  public var timeZone: String
  public var uid: String
  public var token: String?
  public var client: String?
  public var expiry: String?

  // MARK: - Initializers
  init?(
    id: String,
    accountId: String,
    personalAccountId: String,
    accountOwnerId: String,
    accountName: String,
    email: String,
    name: String,
    timeZone: String,
    uid: String,
    token: String,
    client: String,
    expiry: String
  ) {
    self.id = id
    self.accountId = accountId
    self.personalAccountId = personalAccountId
    self.accountOwnerId = accountOwnerId
    self.accountName = accountName
    self.email = email
    self.name = name
    self.timeZone = timeZone
    self.uid = uid
    self.token = token
    self.client = client
    self.expiry = expiry
  }

  init?(dictionary: [String: String]) {
    guard
      let id = dictionary["id"],
      let accountId = dictionary["accountId"],
      let personalAccountId = dictionary["personalAccountId"],
      let accountOwnerId = dictionary["accountOwnerId"],
      let accountName = dictionary["accountName"],
      let email = dictionary["email"],
      let name = dictionary["name"],
      let timeZone = dictionary["timeZone"],
      let uid = dictionary["uid"],
      let token = dictionary["token"],
      let client = dictionary["client"],
      let expiry = dictionary["expiry"]
    else {
      return nil
    }

    self.id = id
    self.accountId = accountId
    self.personalAccountId = personalAccountId
    self.accountOwnerId = accountOwnerId
    self.accountName = accountName
    self.email = email
    self.name = name
    self.timeZone = timeZone
    self.uid = uid
    self.token = token
    self.client = client
    self.expiry = expiry
  }

  public init(from loggedInShopkeeper: LoggedInShopkeeper) {
    id = loggedInShopkeeper.id
    accountId = loggedInShopkeeper.accountId
    personalAccountId = loggedInShopkeeper.personalAccountId
    accountOwnerId = loggedInShopkeeper.accountOwnerId
    accountName = loggedInShopkeeper.accountName
    email = loggedInShopkeeper.email
    name = loggedInShopkeeper.name
    timeZone = loggedInShopkeeper.timeZone
    token = loggedInShopkeeper.token
    client = loggedInShopkeeper.client
    uid = loggedInShopkeeper.uid
    expiry = loggedInShopkeeper.expiry
  }
}

private extension Shopkeeper {
  private init(
    shopkeeper: Shopkeeper
  ) {
    id = shopkeeper.id
    accountId = shopkeeper.accountId
    personalAccountId = shopkeeper.personalAccountId
    accountOwnerId = shopkeeper.accountOwnerId
    accountName = shopkeeper.accountName
    email = shopkeeper.email
    name = shopkeeper.name
    timeZone = shopkeeper.timeZone
    uid = shopkeeper.uid
    token = shopkeeper.token
    client = shopkeeper.client
    expiry = shopkeeper.expiry
  }
}
