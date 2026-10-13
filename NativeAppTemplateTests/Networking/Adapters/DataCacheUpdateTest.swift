//
//  DataCacheUpdateTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// Characterizes DataCacheUpdate.loadFrom(document:). No request calls it today
/// (every Request adapts `doc.data` itself), so this pins what the layer does
/// before it is simplified or removed.
///
/// Attributes follow ShopAdapter (name, time_zone) and ShopkeeperAdapter
/// (email, name, time_zone), the fields they require.
struct DataCacheUpdateTest {
    private func document(_ json: String) throws -> JSONAPIDocument {
        try JSONAPIDocument(JSONSerialization.jsonObject(with: Data(json.utf8)))
    }

    private static let shopAttributes = #"{"name": "Shop", "time_zone": "Tokyo"}"#
    private static let shopkeeperAttributes = #"{"email": "a@example.com", "name": "Name", "time_zone": "Tokyo"}"#

    /// Shops and shopkeepers go into their own lists, data before included
    @Test
    func resourcesAreSortedByTypeWithDataFirst() throws {
        let doc = try document(#"""
        {"data": [{"id": "s1", "type": "shop", "attributes": \#(Self.shopAttributes)}],
         "included": [
            {"id": "k1", "type": "shopkeeper", "attributes": \#(Self.shopkeeperAttributes)},
            {"id": "s2", "type": "shop", "attributes": \#(Self.shopAttributes)}
         ]}
        """#)

        let cacheUpdate = try DataCacheUpdate.loadFrom(document: doc)

        #expect(cacheUpdate.shops.map(\.id) == ["s1", "s2"])
        #expect(cacheUpdate.shopkeepers.map(\.id) == ["k1"])
        #expect(cacheUpdate.shopkeepers.first?.email == "a@example.com")
    }

    /// Only shop and shopkeeper are adapted: an item_tag (a known EntityType) and an
    /// unknown type are skipped without an error
    @Test
    func otherTypesAreSkipped() throws {
        let doc = try document(#"""
        {"data": [
            {"id": "t1", "type": "item_tag", "attributes": {}},
            {"id": "x1", "type": "unknown", "attributes": {}},
            {"id": "s1", "type": "shop", "attributes": \#(Self.shopAttributes)}
        ]}
        """#)

        let cacheUpdate = try DataCacheUpdate.loadFrom(document: doc)

        #expect(cacheUpdate.shops.map(\.id) == ["s1"])
        #expect(cacheUpdate.shopkeepers.isEmpty)
    }

    /// An included resource the adapter rejects fails the whole document
    @Test
    func invalidIncludedResourceFailsTheDocument() throws {
        let doc = try document(#"""
        {"data": [{"id": "s1", "type": "shop", "attributes": \#(Self.shopAttributes)}],
         "included": [{"id": "k1", "type": "shopkeeper", "attributes": {"name": "No email"}}]}
        """#)

        #expect(throws: EntityAdapterError.invalidOrMissingAttributes) {
            try DataCacheUpdate.loadFrom(document: doc)
        }
    }

    /// The data resources' relationships are collected twice: once by the data pass
    /// (from the resources themselves) and again by the included pass (passed in as
    /// additional relationships). A shop with one shopkeeper and two item tags:
    /// 1 + 2 = 3 relationships, collected twice = 6.
    /// A relationship whose target has no EntityType (account) is dropped.
    @Test
    func dataRelationshipsAreCollectedTwice() throws {
        let doc = try document(#"""
        {"data": {"id": "s1", "type": "shop", "attributes": \#(Self.shopAttributes), "relationships": {
            "shopkeeper": {"data": {"id": "k1", "type": "shopkeeper"}},
            "item_tags": {"data": [{"id": "t1", "type": "item_tag"}, {"id": "t2", "type": "item_tag"}]},
            "account": {"data": {"id": "a1", "type": "account"}}
        }}}
        """#)

        let cacheUpdate = try DataCacheUpdate.loadFrom(document: doc)

        #expect(cacheUpdate.relationships.count == 6)
        // Each relationship's name is the key in `relationships`, from the shop
        #expect(cacheUpdate.relationships.allSatisfy { $0.from.id == "s1" && $0.from.type == .shop })
        let pairs = cacheUpdate.relationships.map { "\($0.name)->\($0.to.id)" }.sorted()
        #expect(pairs == [
            "item_tags->t1", "item_tags->t1", "item_tags->t2", "item_tags->t2",
            "shopkeeper->k1", "shopkeeper->k1"
        ])
    }

    /// Relationships of a resource without an EntityType are not collected
    @Test
    func relationshipsOfAnUnknownTypeAreDropped() throws {
        let doc = try document(#"""
        {"data": {"id": "x1", "type": "unknown", "relationships": {
            "shopkeeper": {"data": {"id": "k1", "type": "shopkeeper"}}
        }}}
        """#)

        let cacheUpdate = try DataCacheUpdate.loadFrom(document: doc)

        #expect(cacheUpdate.relationships.isEmpty)
    }

    /// merged(with:) appends the other update's lists after its own
    @Test
    func mergedAppendsInOrder() {
        let first = DataCacheUpdate(shops: [Shop(id: "s1", name: "A", description: "", timeZone: "Tokyo")])
        let second = DataCacheUpdate(shops: [Shop(id: "s2", name: "B", description: "", timeZone: "Tokyo")])

        #expect(first.merged(with: second).shops.map(\.id) == ["s1", "s2"])
        #expect(second.merged(with: first).shops.map(\.id) == ["s2", "s1"])
    }
}
