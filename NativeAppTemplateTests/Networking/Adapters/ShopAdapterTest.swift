//
//  ShopAdapterTest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/01/31.
//

import Testing
import SwiftyJSON
@testable import NativeAppTemplate

struct ShopAdapterTest {
  let sampleResource: JSON = [
    "id": "5712F2DF-DFC7-A3AA-66BC-191203654A1C",
    "type": "shop",
    "attributes": [
      "name": "Shop1",
      "description": "This is a Shop1",
      "time_zone": "Tokyo"
    ],
    "relationships": [
      "account": [
        "data": [
          "id": "96C3444D-5B64-1EFF-2354-55787BD43277",
          "type": "Account1",
          "attributes": [
            "name": "Shop1",
            "owner_id": "88705252-2FD2-4414-9E85-E6888033294B",
            "personal": true,
            "is_admin": true,
            "owner_name": "Jhon Smith",
            "accounts_shopkeepers_count": 99,
            "accounts_invitations_count": 98,
            "shops_count": 96
          ]
        ]
      ]
    ],
    "meta": [
      "limit_count": 96,
      "created_shops_count": 3
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
    let shop = try ShopAdapter.process(resource: resource)
    #expect("5712F2DF-DFC7-A3AA-66BC-191203654A1C" == shop.id)
  }

  @Test func inInvalidTypeThrows() throws {
    var sample = sampleResource
    sample["type"] = "invalid"

    let resource = try makeJsonAPIResource(for: sample)

    #expect { try ShopAdapter.process(resource: resource) } throws: { error in
      let entityAdapterError = error as? EntityAdapterError
      return EntityAdapterError.invalidResourceTypeForAdapter == entityAdapterError
    }
  }

  @Test func missingnNmeThrows() throws {
    var sample = sampleResource
    sample["attributes"].dictionaryObject?.removeValue(forKey: "name")

    let resource = try makeJsonAPIResource(for: sample)

    #expect { try ShopAdapter.process(resource: resource) } throws: { error in
      let entityAdapterError = error as? EntityAdapterError
      return EntityAdapterError.invalidOrMissingAttributes == entityAdapterError
    }
  }
}
