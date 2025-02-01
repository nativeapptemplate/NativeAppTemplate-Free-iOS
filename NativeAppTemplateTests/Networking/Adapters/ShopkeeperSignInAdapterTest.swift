//
//  ShopkeeperSignInAdapterTest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/01/31.
//

import Testing
import SwiftyJSON
@testable import NativeAppTemplate

struct ShopkeeperSignInAdapterTest {
  let sampleResource: JSON = [
    "id": "5712F2DF-DFC7-A3AA-66BC-191203654A1C",
    "type": "shopkeeper_sign_in",
    "attributes": [
      "account_id": "5712F2DF-DFC7-A3AA-66BC-191203654A1Z",
      "personal_account_id": "5712F2DF-DFC7-A3AA-66BC-191203654A1Z",
      "account_owner_id": "5712F2DF-DFC7-A3AA-66BC-191203654A1C",
      "account_name": "Account1",
      "email": "email@example.com",
      "name": "Jhon Smith",
      "time_zone": "Tokyo",
      "uid": "email@example.com"
    ]
  ]

  func makeJsonAPIResource(for dict: JSON) throws -> JSONAPIResource {
    let json: JSON = [
      "data": [
        dict
      ]
    ]

    let document = JSONAPIDocument(json)
    return document.data.first!
  }

  @Test func validResourceProcessedCorrectly() async throws {
    let resource = try makeJsonAPIResource(for: sampleResource)
    let shopkeeper = try ShopkeeperSignInAdapter.process(resource: resource)
    #expect("5712F2DF-DFC7-A3AA-66BC-191203654A1C" == shopkeeper.id)
  }

  @Test func inInvalidTypeThrows() throws {
    var sample = sampleResource
    sample["type"] = "invalid"

    let resource = try makeJsonAPIResource(for: sample)

    #expect { try ShopkeeperSignInAdapter.process(resource: resource) } throws: { error in
      let entityAdapterError = error as? EntityAdapterError
      return EntityAdapterError.invalidResourceTypeForAdapter == entityAdapterError
    }
  }

  @Test func missingnNameThrows() throws {
    var sample = sampleResource
    sample["attributes"].dictionaryObject?.removeValue(forKey: "name")

    let resource = try makeJsonAPIResource(for: sample)

    #expect { try ShopkeeperSignInAdapter.process(resource: resource) } throws: { error in
      let entityAdapterError = error as? EntityAdapterError
      return EntityAdapterError.invalidOrMissingAttributes == entityAdapterError
    }
  }
}
