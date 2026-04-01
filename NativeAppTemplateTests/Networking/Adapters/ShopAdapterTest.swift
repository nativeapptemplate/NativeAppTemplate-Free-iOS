//
//  ShopAdapterTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

struct ShopAdapterTest {
    let sampleResource: [String: Any] = [
        "id": "5712F2DF-DFC7-A3AA-66BC-191203654A1C",
        "type": "shop",
        "attributes": [
            "name": "Shop1",
            "description": "This is a Shop1",
            "time_zone": "Tokyo",
            "display_shop_server_path": "https://api.nativeapptemplate.com/display/shops/1ed7ea32-65d5-4e64-97a0-0e00b6cee8c3?type=server", // swiftlint:disable:this line_length
            "item_tags_count": 10,
            "scanned_item_tags_count": 1,
            "completed_item_tags_count": 2
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
        let shop = try ShopAdapter.process(resource: resource)
        #expect(shop.id == "5712F2DF-DFC7-A3AA-66BC-191203654A1C")
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

    @Test func missingnNameThrows() throws {
        var sample = sampleResource
        if var attributes = sample["attributes"] as? [String: Any] {
            attributes.removeValue(forKey: "name")
            sample["attributes"] = attributes
        }

        let resource = try makeJsonAPIResource(for: sample)

        #expect { try ShopAdapter.process(resource: resource) } throws: { error in
            let entityAdapterError = error as? EntityAdapterError
            return EntityAdapterError.invalidOrMissingAttributes == entityAdapterError
        }
    }
}
