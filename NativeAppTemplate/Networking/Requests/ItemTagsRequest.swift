//
//  ItemTagsRequest.swift
//  NativeAppTemplate
//

import Foundation

struct ItemTagsResponse: Sendable {
    let itemTags: [ItemTag]
    let paginationMeta: PaginationMeta?
}

struct GetItemTagsRequest: Request {
    typealias Response = ItemTagsResponse

    // MARK: - Properties

    var method: HTTPMethod {
        .GET
    }

    var path: String {
        "/shopkeeper/shops/\(shopId)/item_tags"
    }

    var additionalHeaders: [String: String] = [:]

    var queryItems: [URLQueryItem] {
        guard let page else { return [] }
        return [URLQueryItem(name: "page", value: String(page))]
    }

    var body: Data? {
        nil
    }

    let shopId: String
    let page: Int?

    // MARK: - Internal

    func handle(response: Data) throws -> Response {
        let json = try JSONSerialization.jsonObject(with: response)
        let doc = JSONAPIDocument(json)
        let itemTags = try doc.data.map { try ItemTagAdapter.process(resource: $0) }
        let paginationMeta = PaginationMeta(dictionary: doc.meta)
        return ItemTagsResponse(itemTags: itemTags, paginationMeta: paginationMeta)
    }
}

struct GetItemTagDetailRequest: Request {
    typealias Response = ItemTag

    // MARK: - Properties

    var method: HTTPMethod {
        .GET
    }

    var path: String {
        "/shopkeeper/item_tags/\(id)"
    }

    var additionalHeaders: [String: String] = [:]
    var body: Data? {
        nil
    }

    // MARK: - Parameters

    let id: String

    // MARK: - Internal

    func handle(response: Data) throws -> Response {
        let json = try JSONSerialization.jsonObject(with: response)
        let doc = JSONAPIDocument(json)
        let itemTags = try doc.data.map { try ItemTagAdapter.process(resource: $0) }

        guard let itemTag = itemTags.first,
              itemTags.count == 1 else {
            throw NativeAppTemplateAPIError.processingError(nil)
        }

        return itemTag
    }
}

struct MakeItemTagRequest: Request {
    typealias Response = ItemTag

    // MARK: - Properties

    var method: HTTPMethod {
        .POST
    }

    var path: String {
        "/shopkeeper/shops/\(shopId)/item_tags"
    }

    var additionalHeaders: [String: String] = [:]
    var body: Data? {
        let json = itemTag.toJson()
        return try? JSONSerialization.data(withJSONObject: json)
    }

    let shopId: String

    // MARK: - Parameters

    let itemTag: ItemTag

    // MARK: - Internal

    func handle(response: Data) throws -> ItemTag {
        let json = try JSONSerialization.jsonObject(with: response)
        let doc = JSONAPIDocument(json)
        let itemTags = try doc.data.map { try ItemTagAdapter.process(resource: $0) }
        guard let itemTag = itemTags.first,
              itemTags.count == 1 else {
            throw NativeAppTemplateAPIError.responseHasIncorrectNumberOfElements
        }

        return itemTag
    }
}

struct UpdateItemTagRequest: Request {
    typealias Response = ItemTag

    // MARK: - Properties

    var method: HTTPMethod {
        .PATCH
    }

    var path: String {
        "/shopkeeper/item_tags/\(id)"
    }

    var additionalHeaders: [String: String] = [:]
    var body: Data? {
        let json = itemTag.toJson()
        return try? JSONSerialization.data(withJSONObject: json)
    }

    var id: String

    // MARK: - Parameters

    let itemTag: ItemTag

    // MARK: - Internal

    func handle(response: Data) throws -> Response {
        let json = try JSONSerialization.jsonObject(with: response)
        let doc = JSONAPIDocument(json)
        let itemTags = try doc.data.map { try ItemTagAdapter.process(resource: $0) }
        guard let theItemTag = itemTags.first,
              itemTags.count == 1 else {
            throw NativeAppTemplateAPIError.responseHasIncorrectNumberOfElements
        }

        return theItemTag
    }
}

struct DestroyItemTagRequest: Request {
    typealias Response = Void

    // MARK: - Properties

    var method: HTTPMethod {
        .DELETE
    }

    var path: String {
        "/shopkeeper/item_tags/\(id)"
    }

    var additionalHeaders: [String: String] = [:]
    var body: Data? {
        nil
    }

    // MARK: - Parameters

    let id: String

    // MARK: - Internal

    func handle(response: Data) throws {}
}

struct CompleteItemTagRequest: Request {
    typealias Response = ItemTag

    // MARK: - Properties

    var method: HTTPMethod {
        .PATCH
    }

    var path: String {
        "/shopkeeper/item_tags/\(id)/complete"
    }

    var additionalHeaders: [String: String] = [:]
    var body: Data? {
        nil
    }

    // MARK: - Parameters

    let id: String

    // MARK: - Internal

    func handle(response: Data) throws -> Response {
        let json = try JSONSerialization.jsonObject(with: response)
        let doc = JSONAPIDocument(json)
        let itemTags = try doc.data.map { try ItemTagAdapter.process(resource: $0) }
        guard let itemTag = itemTags.first,
              itemTags.count == 1 else {
            throw NativeAppTemplateAPIError.responseHasIncorrectNumberOfElements
        }

        return itemTag
    }
}

struct ResetItemTagRequest: Request {
    typealias Response = ItemTag

    // MARK: - Properties

    var method: HTTPMethod {
        .PATCH
    }

    var path: String {
        "/shopkeeper/item_tags/\(id)/reset"
    }

    var additionalHeaders: [String: String] = [:]
    var body: Data? {
        nil
    }

    // MARK: - Parameters

    let id: String

    // MARK: - Internal

    func handle(response: Data) throws -> Response {
        let json = try JSONSerialization.jsonObject(with: response)
        let doc = JSONAPIDocument(json)
        let itemTags = try doc.data.map { try ItemTagAdapter.process(resource: $0) }
        guard let theItemTag = itemTags.first,
              itemTags.count == 1 else {
            throw NativeAppTemplateAPIError.responseHasIncorrectNumberOfElements
        }

        return theItemTag
    }
}
