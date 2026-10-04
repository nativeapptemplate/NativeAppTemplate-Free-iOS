//
//  KeychainStoreTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Security
import Testing

private struct TestStringKeychainStore: KeychainStore {
    var account = "KeychainStoreTestAccount"
    var service = "com.nativeapptemplate.NativeAppTemplate.KeychainStoreTestService"

    typealias DataType = NSString
}

/// Verifies `KeychainStore` reads and writes items exactly as KeychainAccess v4.2.2 did,
/// using `KeychainOracle` (raw `SecItem*` calls with KeychainAccess's attributes) as the reference.
@Suite(.serialized)
struct KeychainStoreTest {
    private let store = TestStringKeychainStore()

    init() {
        KeychainOracle.delete(service: store.service, account: store.account)
    }

    /// Writes `string` the way KeychainAccess-era app versions did:
    /// archived, then stored with KeychainAccess's attributes.
    private func addLegacyItem(_ string: String) throws -> OSStatus {
        let archived = try NSKeyedArchiver.archivedData(
            withRootObject: string as NSString,
            requiringSecureCoding: true
        )
        return KeychainOracle.add(archived, service: store.service, account: store.account)
    }

    @Test
    func storeWritesKeychainAccessCompatibleItem() throws {
        try store.store("token-1")

        let item = try #require(KeychainOracle.item(service: store.service, account: store.account))
        let unarchived = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSString.self, from: item.data)
        #expect(unarchived == "token-1")
        // KeychainAccess default: Options.accessibility = .afterFirstUnlock
        #expect(item.accessible == kSecAttrAccessibleAfterFirstUnlock as String)
        // KeychainAccess default: Options.synchronizable = false
        #expect(item.synchronizable == false)
    }

    @Test
    func retrieveReadsItemWrittenByKeychainAccess() throws {
        #expect(try addLegacyItem("token-1") == errSecSuccess)

        #expect(try store.retrieve() == "token-1")
    }

    @Test
    func storeOverwritesItemWrittenByKeychainAccess() throws {
        #expect(try addLegacyItem("token-1") == errSecSuccess)

        try store.store("token-2")

        #expect(try store.retrieve() == "token-2")
        #expect(KeychainOracle.count(service: store.service, account: store.account) == 1)
        let item = try #require(KeychainOracle.item(service: store.service, account: store.account))
        #expect(item.accessible == kSecAttrAccessibleAfterFirstUnlock as String)
    }

    @Test
    func retrieveMissingItemThrowsNotFound() {
        #expect {
            try store.retrieve()
        } throws: { error in
            guard case KeychainStoreError.notFound = error else { return false }
            return true
        }
    }

    @Test
    func removeDeletesItemWrittenByKeychainAccess() throws {
        #expect(try addLegacyItem("token-1") == errSecSuccess)

        try store.remove()

        #expect(KeychainOracle.item(service: store.service, account: store.account) == nil)
    }

    @Test
    func removeMissingItemDoesNotThrow() throws {
        try store.remove()
    }
}
