//
//  ItemTagsRequest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/01.
//

import Foundation
import SwiftyJSON

struct GetItemTagsRequest: Request {
  typealias Response = [ItemTag]

  // MARK: - Properties
  var method: HTTPMethod { .GET }
  var path: String { "/shopkeeper/shops/\(shopId)/item_tags" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? { nil }

  let shopId: String

  // MARK: - Internal
  func handle(response: Data) throws -> Response {
    let json = try JSON(data: response)
    let doc = JSONAPIDocument(json)
    let itemTags = try doc.data.map { try ItemTagAdapter.process(resource: $0) }
    return itemTags
  }
}

struct GetItemTagDetailRequest: Request {
  typealias Response = ItemTag

  // MARK: - Properties
  var method: HTTPMethod { .GET }
  var path: String { "/shopkeeper/item_tags/\(id)" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? { nil }
  
  // MARK: - Parameters
  let id: String

  // MARK: - Internal
  func handle(response: Data) throws -> Response {
    let json = try JSON(data: response)
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
  var method: HTTPMethod { .POST }
  var path: String { "/shopkeeper/shops/\(shopId)/item_tags" }
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
    let json = try JSON(data: response)
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
  var method: HTTPMethod { .PATCH }
  var path: String { "/shopkeeper/item_tags/\(id)" }
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
    let json = try JSON(data: response)
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
  var method: HTTPMethod { .DELETE }
  var path: String { "/shopkeeper/item_tags/\(id)" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? { nil }
  
  // MARK: - Parameters
  let id: String
  
  // MARK: - Internal
  func handle(response: Data) throws { }
}

struct CompleteItemTagRequest: Request {
  typealias Response = ItemTag
  
  // MARK: - Properties
  var method: HTTPMethod { .PATCH }
  var path: String { "/shopkeeper/item_tags/\(id)/complete" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? { nil }

  // MARK: - Parameters
  let id: String

  // MARK: - Internal
  func handle(response: Data) throws -> Response {
    let json = try JSON(data: response)
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
  var method: HTTPMethod { .PATCH }
  var path: String { "/shopkeeper/item_tags/\(id)/reset" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? { nil }
  
  // MARK: - Parameters
  let id: String
  
  // MARK: - Internal
  func handle(response: Data) throws -> Response {
    let json = try JSON(data: response)
    let doc = JSONAPIDocument(json)
    let itemTags = try doc.data.map { try ItemTagAdapter.process(resource: $0) }
    guard let theItemTag = itemTags.first,
      itemTags.count == 1 else {
        throw NativeAppTemplateAPIError.responseHasIncorrectNumberOfElements
    }
    
    return theItemTag
  }
}
