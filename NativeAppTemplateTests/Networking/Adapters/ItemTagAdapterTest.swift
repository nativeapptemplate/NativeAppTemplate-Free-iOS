//
//  ItemTagAdapterTest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/01.
//

import Testing
import SwiftyJSON
@testable import NativeAppTemplate

struct ItemTagAdapterTest {
  let sampleResource: JSON = [
    "id": "5712F2DF-DFC7-A3AA-66BC-191203654A1A",
    "type": "item_tag",
    "attributes": [
      "shop_id": "88705252-2FD2-4414-9E85-E6888033294A",
      "queue_number": "A001",
      "state": "idled",
      "scan_state": "unscanned",
      "created_at": "2020-01-01T12:00:00.000Z",
      "shop_name": "Shop1",
      "customer_read_at": "2020-01-02T12:00:00.000Z",
      "completed_at": "2020-01-04T12:00:00.000Z",
      "already_completed": false
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
    let itemTag = try ItemTagAdapter.process(resource: resource)
    #expect("5712F2DF-DFC7-A3AA-66BC-191203654A1A" == itemTag.id)
  }

  @Test func inInvalidTypeThrows() throws {
    var sample = sampleResource
    sample["type"] = "invalid"

    let resource = try makeJsonAPIResource(for: sample)

    #expect { try ItemTagAdapter.process(resource: resource) } throws: { error in
      let entityAdapterError = error as? EntityAdapterError
      return EntityAdapterError.invalidResourceTypeForAdapter == entityAdapterError
    }
  }

  @Test func missingnAccountIdThrows() throws {
    var sample = sampleResource
    sample["attributes"].dictionaryObject?.removeValue(forKey: "shop_id")

    let resource = try makeJsonAPIResource(for: sample)

    #expect { try ItemTagAdapter.process(resource: resource) } throws: { error in
      let entityAdapterError = error as? EntityAdapterError
      return EntityAdapterError.invalidOrMissingAttributes == entityAdapterError
    }
  }
}
