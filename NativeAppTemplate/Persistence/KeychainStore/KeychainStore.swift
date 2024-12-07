//
//  KeychainStore.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2020/04/12.
//  Copyright © 2024 Daisuke Adachi All rights reserved.
//

import Foundation
import KeychainAccess

enum KeychainStoreError: Error {
  case secCallFailed(Error)
  case notFound
  case badData
  case archiveFailure(Error)
}

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

  func retrieve() throws -> DataType {
    let keychain = Keychain(service: service)
    let archived: Data?

    archived = try? keychain.getData(account)
    
    guard archived != nil else {
      throw KeychainStoreError.notFound
    }
    
    do {
      guard
        let unarchived = try NSKeyedUnarchiver.unarchivedObject(ofClass: DataType.self, from: archived!)
        else {
          throw KeychainStoreError.badData
      }

      return unarchived
    } catch {
      throw KeychainStoreError.archiveFailure(error)
    }
  }

  func store(_ data: DataType) throws {
    let archived: Data
    print("data: \(data)")
    do {
      archived = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
    } catch {
      throw KeychainStoreError.archiveFailure(error)
    }
    
    let keychain = Keychain(service: service)
    
    do {
      try keychain.set(archived, key: account)
    } catch {
      throw KeychainStoreError.secCallFailed(error)
    }
  }
}
