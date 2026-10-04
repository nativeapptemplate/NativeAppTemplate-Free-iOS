//
//  Keychain.swift
//  NativeAppTemplate
//

import Foundation
import Security

/// Minimal generic-password keychain wrapper over the Security framework.
///
/// Items use the same attributes KeychainAccess v4.2.2 used with `Keychain(service:)`,
/// so items written by earlier app versions stay readable:
/// - `kSecClassGenericPassword`, keyed by `kSecAttrService` + `kSecAttrAccount`
/// - written with `kSecAttrAccessibleAfterFirstUnlock` and `kSecAttrSynchronizable = false`
/// - read/deleted with `kSecAttrSynchronizableAny`
struct Keychain {
    let service: String

    func data(for account: String) throws -> Data? {
        var query = baseQuery(account: account)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else { throw Self.error(errSecInternalError) }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw Self.error(status)
        }
    }

    func string(for account: String) throws -> String? {
        guard let data = try data(for: account) else { return nil }
        guard let string = String(data: data, encoding: .utf8) else { throw Self.error(errSecDecode) }
        return string
    }

    func set(_ data: Data, for account: String) throws {
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecAttrSynchronizable as String: false
        ]

        let status = SecItemUpdate(baseQuery(account: account) as CFDictionary, attributes as CFDictionary)
        switch status {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            var item = baseQuery(account: account)
            item.merge(attributes) { _, new in new }
            let addStatus = SecItemAdd(item as CFDictionary, nil)
            guard addStatus == errSecSuccess else { throw Self.error(addStatus) }
        default:
            throw Self.error(status)
        }
    }

    func set(_ string: String, for account: String) throws {
        try set(Data(string.utf8), for: account)
    }

    func remove(_ account: String) throws {
        let status = SecItemDelete(baseQuery(account: account) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw Self.error(status) }
    }

    private func baseQuery(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: kSecAttrSynchronizableAny
        ]
    }

    private static func error(_ status: OSStatus) -> NSError {
        let message = SecCopyErrorMessageString(status, nil) as String? ?? "OSStatus \(status)"
        return NSError(
            domain: NSOSStatusErrorDomain,
            code: Int(status),
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }
}
