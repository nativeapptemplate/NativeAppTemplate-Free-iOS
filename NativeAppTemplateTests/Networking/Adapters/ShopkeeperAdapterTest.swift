//
//  ShopkeeperAdapterTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

struct ShopkeeperAdapterTest {
    let sampleResource: [String: Any] = [
        "id": "5712F2DF-DFC7-A3AA-66BC-191203654A1C",
        "type": "shopkeeper",
        "attributes": [
            "name": "Shopkeeper1",
            "email": "email@example.com",
            "time_zone": "Tokyo"
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
        let shopkeeper = try ShopkeeperAdapter.process(resource: resource)
        #expect(shopkeeper.id == "5712F2DF-DFC7-A3AA-66BC-191203654A1C")
    }

    @Test func inInvalidTypeThrows() throws {
        var sample = sampleResource
        sample["type"] = "invalid"

        let resource = try makeJsonAPIResource(for: sample)

        #expect { try ShopkeeperAdapter.process(resource: resource) } throws: { error in
            let entityAdapterError = error as? EntityAdapterError
            return EntityAdapterError.invalidResourceTypeForAdapter == entityAdapterError
        }
    }

    @Test func missingnNameThrows() throws {
        var sample = sampleResource
        if var attributes = sample["attributes"] as? [String: Any] {
            attributes.removeValue(forKey: "name")
            sample["attributes"] = attributes
        }

        let resource = try makeJsonAPIResource(for: sample)

        #expect { try ShopkeeperAdapter.process(resource: resource) } throws: { error in
            let entityAdapterError = error as? EntityAdapterError
            return EntityAdapterError.invalidOrMissingAttributes == entityAdapterError
        }
    }
}
