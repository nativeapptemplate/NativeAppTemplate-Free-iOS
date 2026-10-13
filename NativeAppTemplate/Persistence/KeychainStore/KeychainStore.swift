//
//  KeychainStore.swift
//  NativeAppTemplate
//

import Foundation

protocol KeychainStore {
    associatedtype DataType: NSObject, NSCoding

    var account: String { get set }
    var service: String { get set }

    func remove() throws
    func retrieve() throws -> DataType
    func store(_ data: DataType) throws
}

extension KeychainStore {
    func remove() throws {
        let keychain = Keychain(service: service)

        do {
            try keychain.remove(account)
        } catch {
            throw KeychainStoreError.secCallFailed(error)
        }
    }

    /// - Throws: `notFound` when there is no item, `secCallFailed` when the keychain
    ///   can't be read, and `archiveFailure` when the item can't be decoded as `DataType`
    func retrieve() throws -> DataType {
        let keychain = Keychain(service: service)

        let archived: Data?
        do {
            archived = try keychain.data(for: account)
        } catch {
            throw KeychainStoreError.secCallFailed(error)
        }

        guard let archived else {
            throw KeychainStoreError.notFound
        }

        let unarchived: DataType?
        do {
            unarchived = try NSKeyedUnarchiver.unarchivedObject(ofClass: DataType.self, from: archived)
        } catch {
            throw KeychainStoreError.archiveFailure(error)
        }

        // An archive of another class decodes to nil without an error
        guard let unarchived else {
            throw KeychainStoreError.archiveFailure(KeychainStoreError.badData)
        }

        return unarchived
    }

    func store(_ data: DataType) throws {
        let archived: Data
        do {
            archived = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
        } catch {
            throw KeychainStoreError.archiveFailure(error)
        }

        let keychain = Keychain(service: service)

        do {
            try keychain.set(archived, for: account)
        } catch {
            throw KeychainStoreError.secCallFailed(error)
        }
    }
}
