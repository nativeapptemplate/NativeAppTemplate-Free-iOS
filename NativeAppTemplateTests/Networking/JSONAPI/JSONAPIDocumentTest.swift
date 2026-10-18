//
//  JSONAPIDocumentTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// Characterizes how JSONAPIDocument and JSONAPIResource read a JSON:API document
/// (https://jsonapi.org/format/#document-structure) as the API's jsonapi-serializer
/// gem writes it: `data` is an object for one resource and an array for a collection.
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

    /// A missing id or type reads as "", which matches no EntityType
    @Test
    func resourceWithoutIdOrTypeHasEmptyStringsAndNoEntityType() throws {
        let doc = try document(#"{"data": {"attributes": {"name": "A"}}}"#)
        let resource = try #require(doc.data.first)

        #expect(resource.id.isEmpty)
        #expect(resource.type.isEmpty)
        #expect(resource.entityType == nil)
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
        let resource = try #require(doc.data.first)

        #expect(resource.entityType == expected)
        #expect(resource.id == "7")
    }

    /// Only those exact names: a type EntityType does not list (the paid app's account),
    /// camelCase, or capitalized has none. The camelCase one keeps a part the agent does
    /// not rename: it renames item_tag and itemTag to the same word, so a camelCase
    /// item tag type would become a known one in the generated app.
    @Test(arguments: ["account", "shopkeeperSignIn", "Shop"])
    func otherTypeNamesHaveNoEntityType(type: String) throws {
        let doc = try document(#"{"data": {"id": "1", "type": "\#(type)"}}"#)

        #expect(doc.data.first?.entityType == nil)
    }

    /// Anything but a JSON object (e.g. an array body) is an empty document, not an error
    @Test
    func nonObjectJsonIsAnEmptyDocument() throws {
        let doc = try document(#"[{"id": "1", "type": "shop"}]"#)

        #expect(doc.data.isEmpty)
        #expect(doc.included.isEmpty)
        #expect(doc.meta.isEmpty)
    }
}
