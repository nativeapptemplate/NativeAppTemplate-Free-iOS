//
//  LoggedInShopkeeperKeychainStore.swift
//  NativeAppTemplate
//

import Foundation

struct LoggedInShopkeeperKeychainStore: KeychainStore {
    // Make sure the account name doesn't match the bundle identifier!
    var account = String.keychainAccountLoggedInShopkeeper
    var service = String.keychainServiceLoggedInShopkeeper

    typealias DataType = LoggedInShopkeeper
}
