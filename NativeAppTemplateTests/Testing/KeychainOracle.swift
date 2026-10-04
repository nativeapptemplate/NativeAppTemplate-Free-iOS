//
//  KeychainOracle.swift
//  NativeAppTemplate
//

import Foundation
import Security

/// Raw `SecItem*` access that reproduces how KeychainAccess v4.2.2 stored items
/// (`Lib/KeychainAccess/Keychain.swift`, `Options.query()` / `Options.attributes(key:value:)`
/// with the defaults of `Keychain(service:)`):
/// - `kSecClass`: `kSecClassGenericPassword`, keyed by `kSecAttrService` + `kSecAttrAccount`
/// - `kSecAttrAccessible`: `kSecAttrAccessibleAfterFirstUnlock` (`Options.accessibility = .afterFirstUnlock`)
/// - `kSecAttrSynchronizable`: `false` on write (`Options.synchronizable = false`),
///   `kSecAttrSynchronizableAny` on read/delete (`ignoringAttributeSynchronizable = true`)
///
/// Items already on users' devices were written this way, so the app must keep reading them.
enum KeychainOracle {
    struct Item {
        let data: Data
        let accessible: String
        let synchronizable: Bool
    }

    static func add(_ data: Data, service: String, account: String) -> OSStatus {
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecAttrSynchronizable as String: kCFBooleanFalse as Any
        ]
        return SecItemAdd(attributes as CFDictionary, nil)
    }

    static func item(service: String, account: String) -> Item? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: kSecAttrSynchronizableAny,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true,
            kSecReturnAttributes as String: true
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let attributes = result as? [String: Any],
              let data = attributes[kSecValueData as String] as? Data
        else {
            return nil
        }
        return Item(
            data: data,
            accessible: attributes[kSecAttrAccessible as String] as? String ?? "",
            synchronizable: (attributes[kSecAttrSynchronizable as String] as? NSNumber)?.boolValue ?? false
        )
    }

    static func count(service: String, account: String) -> Int {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: kSecAttrSynchronizableAny,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: true
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess else { return 0 }
        return (result as? [[String: Any]])?.count ?? 0
    }

    static func delete(service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: kSecAttrSynchronizableAny
        ]
        SecItemDelete(query as CFDictionary)
    }
}
