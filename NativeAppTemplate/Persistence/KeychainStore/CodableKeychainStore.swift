//
//  CodableKeychainStore.swift
//  NativeAppTemplate
//

import Foundation

/// A Keychain item holding one `Codable` value, stored as JSON. Use it for a new item, so a
/// value to keep needs no NSCoding class (`KeychainStore` keeps the items KeychainAccess wrote).
/// Items are written like `KeychainStore`'s: this device only, not synchronized. Add a new
/// item to `KeychainReinstallCleanup.appItems`.
protocol CodableKeychainStore {
    associatedtype DataType: Codable

    var account: String { get }
    var service: String { get }

    func remove() throws
    func retrieve() throws -> DataType
    func store(_ data: DataType) throws
}

extension CodableKeychainStore {
    func remove() throws {
        do {
            try Keychain(service: service).remove(account)
        } catch {
            throw KeychainStoreError.secCallFailed(error)
        }
    }

    /// - Throws: `notFound` when there is no item, `secCallFailed` when the keychain
    ///   can't be read, and `archiveFailure` when the item can't be decoded as `DataType`
    func retrieve() throws -> DataType {
        let encoded: Data?
        do {
            encoded = try Keychain(service: service).data(for: account)
        } catch {
            throw KeychainStoreError.secCallFailed(error)
        }

        guard let encoded else {
            throw KeychainStoreError.notFound
        }

        do {
            return try JSONDecoder().decode(DataType.self, from: encoded)
        } catch {
            throw KeychainStoreError.archiveFailure(error)
        }
    }

    func store(_ data: DataType) throws {
        let encoded: Data
        do {
            encoded = try JSONEncoder().encode(data)
        } catch {
            throw KeychainStoreError.archiveFailure(error)
        }

        do {
            try Keychain(service: service).set(encoded, for: account)
        } catch {
            throw KeychainStoreError.secCallFailed(error)
        }
    }
}
