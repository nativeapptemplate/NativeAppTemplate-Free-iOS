//
//  ItemTagTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

struct ItemTagTest {
    @Test
    func toJsonWrapsFieldsUnderItemTagKey() throws {
        var itemTag = ItemTag()
        itemTag.name = "Table 1"
        itemTag.description = "Window seat"

        let json = itemTag.toJson()
        let inner = try #require(json["item_tag"] as? [String: Any])

        #expect(inner["name"] as? String == "Table 1")
        #expect(inner["description"] as? String == "Window seat")
    }

    @Test
    func toJsonOnlyIncludesNameAndDescription() throws {
        var itemTag = ItemTag()
        itemTag.id = "abc-123"
        itemTag.shopId = "shop-1"
        itemTag.name = "n"
        itemTag.description = "d"
        itemTag.position = 5
        itemTag.shopName = "Cafe"

        let json = itemTag.toJson()
        let inner = try #require(json["item_tag"] as? [String: Any])

        #expect(inner.keys.sorted() == ["description", "name"])
    }

    @Test
    func defaultsAreEmptyAndIdled() {
        let itemTag = ItemTag()
        #expect(itemTag.id.isEmpty)
        #expect(itemTag.shopId.isEmpty)
        #expect(itemTag.name.isEmpty)
        #expect(itemTag.description.isEmpty)
        #expect(itemTag.position == 0)
        #expect(itemTag.state == .idled)
        #expect(itemTag.completedAt == nil)
    }
}
