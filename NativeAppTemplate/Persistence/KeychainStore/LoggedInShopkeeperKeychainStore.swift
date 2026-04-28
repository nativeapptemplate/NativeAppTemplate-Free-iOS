//
//  LoggedInShopkeeperKeychainStore.swift
//  NativeAppTemplate
//

import Foundation

struct LoggedInShopkeeperKeychainStore: KeychainStore {
    // Make sure the account name doesn't match the bundle identifier!
    var account = Strings.keychainAccountLoggedInShopkeeper
    var service = Strings.keychainServiceLoggedInShopkeeper

    typealias DataType = LoggedInShopkeeper
}
