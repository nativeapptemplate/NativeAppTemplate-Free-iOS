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

/// Its own item, so the app's saved session (LoggedInShopkeeperKeychainStore) is left alone
private struct TestLoggedInShopkeeperKeychainStore: KeychainStore {
    var account = "KeychainStoreTestLoggedInShopkeeperAccount"
    var service = "com.nativeapptemplate.NativeAppTemplate.KeychainStoreTestService"

    typealias DataType = LoggedInShopkeeper
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
        // This device only, so a restored backup on another device carries no session
        #expect(item.accessible == kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String)
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
        // Saving again moves an item KeychainAccess wrote to this device only
        #expect(item.accessible == kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String)
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

    // MARK: - Unreadable items (characterization)

    /// The KeychainStoreError case `retrieve()` throws, with an archiveFailure's
    /// payload when that is a KeychainStoreError too
    private func retrieveError(_ retrieve: () throws -> Any) -> String? {
        func name(_ error: KeychainStoreError) -> String {
            switch error {
            case .secCallFailed: "secCallFailed"
            case .notFound: "notFound"
            case .badData: "badData"
            case let .archiveFailure(underlying as KeychainStoreError): "archiveFailure(\(name(underlying)))"
            case .archiveFailure: "archiveFailure"
            }
        }

        do {
            _ = try retrieve()
            return nil
        } catch let error as KeychainStoreError {
            return name(error)
        } catch {
            return "\(error)"
        }
    }

    /// Bytes that are no keyed archive: NSKeyedUnarchiver throws, and retrieve()
    /// wraps that in archiveFailure
    @Test
    func retrieveOfNonArchiveBytesIsAnArchiveFailure() {
        let status = KeychainOracle.add(Data("not an archive".utf8), service: store.service, account: store.account)
        #expect(status == errSecSuccess)

        #expect(retrieveError { try store.retrieve() } == "archiveFailure")
    }

    /// An archive of another class (NSNumber where NSString is expected):
    /// NSKeyedUnarchiver.unarchivedObject returns nil without throwing, and
    /// retrieve() throws archiveFailure wrapping badData
    @Test
    func retrieveOfAnotherClassIsAnArchiveFailureOfBadData() throws {
        let archived = try NSKeyedArchiver.archivedData(withRootObject: NSNumber(value: 1), requiringSecureCoding: true)
        #expect(KeychainOracle.add(archived, service: store.service, account: store.account) == errSecSuccess)

        #expect(retrieveError { try store.retrieve() } == "archiveFailure(badData)")
    }

    /// A keyed archive without a root object: NSKeyedUnarchiver throws
    /// ("requested key: 'root'", NSCocoaErrorDomain 4865), so this is archiveFailure
    @Test
    func retrieveOfAnArchiveWithoutARootIsAnArchiveFailure() {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        archiver.finishEncoding()
        let status = KeychainOracle.add(archiver.encodedData, service: store.service, account: store.account)
        #expect(status == errSecSuccess)

        #expect(retrieveError { try store.retrieve() } == "archiveFailure")
    }

    /// An unreadable item stays in the keychain: retrieve() only reads
    @Test
    func failedRetrieveKeepsTheItem() {
        let status = KeychainOracle.add(Data("not an archive".utf8), service: store.service, account: store.account)
        #expect(status == errSecSuccess)

        _ = retrieveError { try store.retrieve() }

        #expect(KeychainOracle.count(service: store.service, account: store.account) == 1)
    }

    /// A saved session missing `token` (see LoggedInShopkeeperTest): init?(coder:)
    /// returns nil, NSKeyedUnarchiver throws for it, and retrieve() throws
    /// archiveFailure, so LoginRepository treats the user as signed out
    @Test
    func retrieveOfADamagedLoggedInShopkeeperIsAnArchiveFailure() throws {
        let shopkeeperStore = TestLoggedInShopkeeperKeychainStore()
        KeychainOracle.delete(service: shopkeeperStore.service, account: shopkeeperStore.account)
        defer { KeychainOracle.delete(service: shopkeeperStore.service, account: shopkeeperStore.account) }

        /// PartialLoggedInShopkeeper archived under LoggedInShopkeeper's class name
        func add(missingKey: String) throws -> OSStatus {
            let archiver = NSKeyedArchiver(requiringSecureCoding: true)
            archiver.setClassName(NSStringFromClass(LoggedInShopkeeper.self), for: PartialLoggedInShopkeeper.self)
            archiver.encode(PartialLoggedInShopkeeper(missingKey: missingKey), forKey: NSKeyedArchiveRootObjectKey)
            archiver.finishEncoding()
            KeychainOracle.delete(service: shopkeeperStore.service, account: shopkeeperStore.account)
            return KeychainOracle.add(
                archiver.encodedData,
                service: shopkeeperStore.service,
                account: shopkeeperStore.account
            )
        }

        // Guard: with nothing missing, the same archive is read back
        #expect(try add(missingKey: "") == errSecSuccess)
        #expect(try shopkeeperStore.retrieve().token == "token-value")

        #expect(try add(missingKey: "token") == errSecSuccess)
        #expect(retrieveError { try shopkeeperStore.retrieve() } == "archiveFailure")
    }
}
