//
//  ItemTagAdapterTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

struct ItemTagAdapterTest {
    let sampleResource: [String: Any] = [
        "id": "5712F2DF-DFC7-A3AA-66BC-191203654A1A",
        "type": "item_tag",
        "attributes": [
            "shop_id": "88705252-2FD2-4414-9E85-E6888033294A",
            "name": "A001",
            "description": "",
            "position": 1,
            "state": "idled",
            "created_at": "2020-01-01T12:00:00.000Z",
            "shop_name": "Shop1",
            "completed_at": "2020-01-04T12:00:00.000Z"
        ]
    ]

    func makeJsonAPIResource(for dict: [String: Any]) throws -> JSONAPIResource {
        let json: [String: Any] = [
            "data": [
                dict
            ]
        ]

        let document = JSONAPIDocument(json)
        return document.data.first!
    }

    @Test func validResourceProcessedCorrectly() throws {
        let resource = try makeJsonAPIResource(for: sampleResource)
        let itemTag = try ItemTagAdapter.process(resource: resource)
        #expect(itemTag.id == "5712F2DF-DFC7-A3AA-66BC-191203654A1A")
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
        if var attributes = sample["attributes"] as? [String: Any] {
            attributes.removeValue(forKey: "shop_id")
            sample["attributes"] = attributes
        }

        let resource = try makeJsonAPIResource(for: sample)

        #expect { try ItemTagAdapter.process(resource: resource) } throws: { error in
            let entityAdapterError = error as? EntityAdapterError
            return EntityAdapterError.invalidOrMissingAttributes == entityAdapterError
        }
    }

    @Test func missingPositionThrows() throws {
        var sample = sampleResource
        if var attributes = sample["attributes"] as? [String: Any] {
            attributes.removeValue(forKey: "position")
            sample["attributes"] = attributes
        }

        let resource = try makeJsonAPIResource(for: sample)

        #expect { try ItemTagAdapter.process(resource: resource) } throws: { error in
            let entityAdapterError = error as? EntityAdapterError
            return EntityAdapterError.invalidOrMissingAttributes == entityAdapterError
        }
    }
}
