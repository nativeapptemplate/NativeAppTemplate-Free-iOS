//
//  JSONAPIDocumentTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// Characterizes how JSONAPIDocument, JSONAPIResource and JSONAPIRelationship read a
/// JSON:API document (https://jsonapi.org/format/#document-structure) as the API's
/// jsonapi-serializer gem writes it: `data` is an object for one resource and an array
/// for a collection, `relationships` map a name to `{ "data": identifier | [identifier] | null }`.
struct JSONAPIDocumentTest {
    private func document(_ json: String) throws -> JSONAPIDocument {
        try JSONAPIDocument(JSONSerialization.jsonObject(with: Data(json.utf8)))
    }

    @Test
    func singleResourceDataBecomesAOneElementArray() throws {
        let doc = try document(#"{"data": {"id": "1", "type": "shop", "attributes": {"name": "A"}}}"#)

        #expect(doc.data.count == 1)
        #expect(doc.data.first?.id == "1")
        #expect(doc.data.first?.type == "shop")
        #expect(doc.data.first?.attributes["name"] as? String == "A")
        #expect(doc.included.isEmpty)
    }

    @Test
    func collectionDataKeepsItsOrder() throws {
        let doc = try document(#"{"data": [{"id": "2", "type": "shop"}, {"id": "1", "type": "shop"}]}"#)

        #expect(doc.data.map(\.id) == ["2", "1"])
    }

    /// `included` is an array in JSON:API; a single object is read as one resource too
    @Test
    func includedIsReadAsArrayOrObject() throws {
        let array = try document(#"{"data": [], "included": [{"id": "k", "type": "shopkeeper"}]}"#)
        let object = try document(#"{"data": [], "included": {"id": "k", "type": "shopkeeper"}}"#)

        #expect(array.included.map(\.id) == ["k"])
        #expect(object.included.map(\.id) == ["k"])
    }

    /// The API's GET /shopkeeper/shops meta (GetShopsRequest reads both)
    @Test
    func metaIsKeptAsIs() throws {
        let doc = try document(#"{"data": [], "meta": {"limit_count": 99, "created_shops_count": 3}}"#)

        #expect(doc.meta["limit_count"] as? Int == 99)
        #expect(doc.meta["created_shops_count"] as? Int == 3)
    }

    /// Only string links that parse as URLs are kept; a links object
    /// (`{"href": ...}`, allowed by JSON:API) and null are dropped
    @Test
    func onlyStringLinksAreKept() throws {
        let doc = try document(#"""
        {"data": {"id": "1", "type": "shop", "links": {"self": "https://example.com/shops/1", "related": {"href": "https://example.com"}}},
         "links": {"next": "https://example.com/shops?page=2", "prev": null}}
        """#)

        let next = try #require(URL(string: "https://example.com/shops?page=2"))
        let selfLink = try #require(URL(string: "https://example.com/shops/1"))
        #expect(doc.links == ["next": next])
        #expect(doc.data.first?.links == ["self": selfLink])
    }

    /// A resource's own meta is kept
    @Test
    func resourceMetaIsKept() throws {
        let doc = try document(#"{"data": {"id": "1", "type": "shop", "meta": {"position": 2}}}"#)

        #expect(doc.data.first?.meta["position"] as? Int == 2)
    }

    /// Resources in `data` and `included` point back to their document (weakly)
    @Test
    func resourcesKnowTheirDocument() throws {
        let doc = try document(#"""
        {"data": {"id": "1", "type": "shop"}, "included": [{"id": "k", "type": "shopkeeper"}]}
        """#)

        #expect(doc.data.first?.parent === doc)
        #expect(doc.included.first?.parent === doc)
    }

    /// A missing id or type reads as "" (not the property's initial "0"), which
    /// matches no EntityType
    @Test
    func resourceWithoutIdOrTypeHasEmptyStringsAndNoEntityID() throws {
        let doc = try document(#"{"data": {"attributes": {"name": "A"}}}"#)
        let resource = try #require(doc.data.first)

        #expect(resource.id.isEmpty)
        #expect(resource.type.isEmpty)
        #expect(resource.entityType == nil)
        #expect(resource.entityID == nil)
    }

    /// EntityType(from:) knows the API's snake_case type names (the serializers'
    /// set_type: shop, shopkeeper, shopkeeper_sign_in, item_tag)
    @Test(arguments: [
        ("shop", EntityType.shop),
        ("shopkeeper", .shopkeeper),
        ("shopkeeper_sign_in", .shopkeeperSignIn),
        ("item_tag", .itemTag)
    ])
    func entityTypeFromTypeName(type: String, expected: EntityType) throws {
        let doc = try document(#"{"data": {"id": "7", "type": "\#(type)"}}"#)
        let entityID = try #require(doc.data.first?.entityID)

        #expect(entityID.type == expected)
        #expect(entityID.id == "7")
    }

    /// Only those exact names: camelCase, capitalized, or a type EntityType does not
    /// list (the paid app's account) has none
    @Test(arguments: ["itemTag", "Shop", "account"])
    func otherTypeNamesHaveNoEntityType(type: String) throws {
        let doc = try document(#"{"data": {"id": "1", "type": "\#(type)"}}"#)

        #expect(doc.data.first?.entityType == nil)
        #expect(doc.data.first?.entityID == nil)
    }

    /// To-one, to-many and null relationships
    @Test
    func toOneToManyAndNullRelationships() throws {
        let doc = try document(#"""
        {"data": {"id": "1", "type": "shop", "relationships": {
            "shopkeeper": {"data": {"id": "k1", "type": "shopkeeper"}},
            "item_tags": {"data": [{"id": "t1", "type": "item_tag"}, {"id": "t2", "type": "item_tag"}]},
            "owner": {"data": null, "meta": {"count": 0}}
        }}}
        """#)
        let relationships = try #require(doc.data.first?.relationships)
        // Not uniqueKeysWithValues: a duplicate name would trap and end the test run
        let byName = Dictionary(relationships.map { ($0.type, $0) }) { first, _ in first }

        // The relationship's `type` is its name, not the related resource's type
        #expect(relationships.count == 3)
        #expect(Set(byName.keys) == ["shopkeeper", "item_tags", "owner"])
        #expect(byName["shopkeeper"]?.data.map(\.id) == ["k1"])
        #expect(byName["shopkeeper"]?.data.first?.type == "shopkeeper")
        #expect(byName["item_tags"]?.data.map(\.id) == ["t1", "t2"])
        #expect(byName["owner"]?.data.isEmpty == true)
        #expect(byName["owner"]?.meta["count"] as? Int == 0)
        // Resource identifiers inside a relationship have no document
        #expect(byName["shopkeeper"]?.data.first?.parent == nil)
    }

    /// A relationship that is not an object is kept with no name and no data
    @Test
    func nonObjectRelationshipHasNoNameOrData() throws {
        let doc = try document(#"{"data": {"id": "1", "type": "shop", "relationships": {"shopkeeper": "k1"}}}"#)
        let relationship = try #require(doc.data.first?.relationships.first)

        #expect(doc.data.first?.relationships.count == 1)
        #expect(relationship.type.isEmpty)
        #expect(relationship.data.isEmpty)
    }

    /// Anything but a JSON object (e.g. an array body) is an empty document, not an error
    @Test
    func nonObjectJsonIsAnEmptyDocument() throws {
        let doc = try document(#"[{"id": "1", "type": "shop"}]"#)

        #expect(doc.data.isEmpty)
        #expect(doc.included.isEmpty)
        #expect(doc.meta.isEmpty)
        #expect(doc.links.isEmpty)
    }
}
