//
//  ShopTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

struct ShopTest {
    private func makeShop() -> Shop {
        Shop(
            id: "shop-1",
            name: "Cafe",
            description: "A nice cafe",
            timeZone: "Asia/Tokyo"
        )
    }

    @Test
    func toJsonForCreateWrapsFieldsUnderShopKey() throws {
        let shop = makeShop()

        let json = shop.toJsonForCreate()
        let inner = try #require(json["shop"] as? [String: Any])

        #expect(inner["name"] as? String == "Cafe")
        #expect(inner["description"] as? String == "A nice cafe")
        #expect(inner["time_zone"] as? String == "Asia/Tokyo")
    }

    @Test
    func toJsonForCreateExcludesIdAndCounts() throws {
        let shop = makeShop()
        let inner = try #require(shop.toJsonForCreate()["shop"] as? [String: Any])

        #expect(inner["id"] == nil)
        #expect(inner["item_tags_count"] == nil)
        #expect(inner["completed_item_tags_count"] == nil)
        #expect(inner.keys.sorted() == ["description", "name", "time_zone"])
    }

    @Test
    func toJsonForUpdateMatchesCreateShape() throws {
        let shop = makeShop()
        let create = try #require(shop.toJsonForCreate()["shop"] as? [String: Any])
        let update = try #require(shop.toJsonForUpdate()["shop"] as? [String: Any])

        #expect(create.keys.sorted() == update.keys.sorted())
        #expect(create["name"] as? String == update["name"] as? String)
        #expect(create["description"] as? String == update["description"] as? String)
        #expect(create["time_zone"] as? String == update["time_zone"] as? String)
    }

    @Test
    func defaultCountsAreZero() {
        let shop = makeShop()
        #expect(shop.itemTagsCount == 0)
        #expect(shop.completedItemTagsCount == 0)
    }
}
