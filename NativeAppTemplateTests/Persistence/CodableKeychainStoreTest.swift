//
//  CodableKeychainStoreTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Security
import Testing

/// A value with a date and an optional, the kinds an NSCoding class had to write out by hand
private struct TestValue: Codable, Equatable {
    let token: String
    let receivedAt: Date
    let note: String?
}

private struct TestCodableKeychainStore: CodableKeychainStore {
    let account = "CodableKeychainStoreTestAccount"
    let service = "com.nativeapptemplate.NativeAppTemplate.CodableKeychainStoreTestService"

    typealias DataType = TestValue
}

/// A Codable value goes into the Keychain without an NSCoding class, and comes back equal
@Suite(.serialized)
struct CodableKeychainStoreTest {
    private let store = TestCodableKeychainStore()
    // A whole second: JSONEncoder writes a date as a Double, which round-trips it exactly
    private let value = TestValue(token: "ABC123", receivedAt: Date(timeIntervalSince1970: 1_792_800_000), note: nil)

    init() {
        KeychainOracle.delete(service: store.service, account: store.account)
    }

    @Test
    func storedValueComesBackEqual() throws {
        try store.store(value)

        #expect(try store.retrieve() == value)
    }

    @Test
    func itemIsThisDeviceOnlyAndNotSynchronized() throws {
        try store.store(value)

        let item = try #require(KeychainOracle.item(service: store.service, account: store.account))
        #expect(item.accessible == kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String)
        #expect(item.synchronizable == false)
    }

    @Test
    func storingAgainReplacesTheValue() throws {
        try store.store(value)
        let newer = TestValue(token: "XYZ789", receivedAt: value.receivedAt, note: "second")

        try store.store(newer)

        #expect(try store.retrieve() == newer)
        #expect(KeychainOracle.count(service: store.service, account: store.account) == 1)
    }

    @Test
    func retrieveMissingItemThrowsNotFound() {
        #expect {
            try store.retrieve()
        } throws: { error in
            guard case .notFound = error as? KeychainStoreError else { return false }
            return true
        }
    }

    /// Bytes that are not this type's JSON are an archive failure, as a bad archive is for KeychainStore
    @Test
    func retrieveOfOtherBytesIsAnArchiveFailure() throws {
        #expect(KeychainOracle.add(Data("not json".utf8), service: store.service, account: store.account) == errSecSuccess)

        #expect {
            try store.retrieve()
        } throws: { error in
            guard case .archiveFailure = error as? KeychainStoreError else { return false }
            return true
        }
    }

    @Test
    func removeDeletesTheItem() throws {
        try store.store(value)

        try store.remove()

        #expect(KeychainOracle.count(service: store.service, account: store.account) == 0)
    }
}
