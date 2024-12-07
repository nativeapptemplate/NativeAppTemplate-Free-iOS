//
//  LoggedInShopkeeperStore.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2021/01/17.
//

import Foundation

struct LoggedInShopkeeperKeychainStore: KeychainStore {
  // Make sure the account name doesn't match the bundle identifier!
  var account = String.keychainAccountLoggedInShopkeeper
  var service = String.keychainServiceLoggedInShopkeeper

  typealias DataType = LoggedInShopkeeper
}
