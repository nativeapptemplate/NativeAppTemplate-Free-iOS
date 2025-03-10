//
//  ShopsRequest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2022/07/02.
//

import Foundation
import SwiftyJSON

struct GetShopsRequest: Request {
  typealias Response = (shops: [Shop], limitCount: Int, createdShopsCount: Int)

  // MARK: - Properties
  var method: HTTPMethod { .GET }
  var path: String { "/shopkeeper/shops" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? { nil }

  // MARK: - Internal
  func handle(response: Data) throws -> Response {
    let json = try JSON(data: response)
    let doc = JSONAPIDocument(json)
    let shops = try doc.data.map { try ShopAdapter.process(resource: $0) }
    guard let limitCount = doc.meta["limit_count"] as? Int else {
      throw NativeAppTemplateAPIError.responseMissingRequiredMeta(field: "limit_count")
    }

    guard let createdShopsCount = doc.meta["created_shops_count"] as? Int else {
      throw NativeAppTemplateAPIError.responseMissingRequiredMeta(field: "created_shops_count")
    }

    return (shops: shops, limitCount: limitCount, createdShopsCount: createdShopsCount)
  }
}

struct GetShopDetailRequest: Request {
//  typealias Response = (shop: Shop, cacheUpdate: DataCacheUpdate)
  typealias Response = Shop

  // MARK: - Properties
  var method: HTTPMethod { .GET }
  var path: String { "/shopkeeper/shops/\(id)" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? { nil }
  
  // MARK: - Parameters
  let id: String

  // MARK: - Internal
  func handle(response: Data) throws -> Response {
    let json = try JSON(data: response)
    let doc = JSONAPIDocument(json)
    let shops = try doc.data.map { try ShopAdapter.process(resource: $0) }
    
    guard let shop = shops.first,
          shops.count == 1 else {
        throw NativeAppTemplateAPIError.processingError(nil)
    }
    
    return shop
  }
}

struct MakeShopRequest: Request {
  typealias Response = Shop
  
  // MARK: - Properties
  var method: HTTPMethod { .POST }
  var additionalHeaders: [String: String] = [:]
  var body: Data? {
    let json = shop.toJsonForCreate()
    return try? JSONSerialization.data(withJSONObject: json)
  }
  var path: String { "/shopkeeper/shops" }

  // MARK: - Parameters
  let shop: Shop

  // MARK: - Internal
  func handle(response: Data) throws -> Shop {
    let json = try JSON(data: response)
    let doc = JSONAPIDocument(json)
    let shops = try doc.data.map { try ShopAdapter.process(resource: $0) }
    guard let shop = shops.first,
      shops.count == 1 else {
        throw NativeAppTemplateAPIError.responseHasIncorrectNumberOfElements
    }
    
    return shop
  }
}

struct UpdateShopRequest: Request {
  typealias Response = Shop
  
  // MARK: - Properties
  var method: HTTPMethod { .PATCH }
  var path: String { "/shopkeeper/shops/\(id)" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? {
    let json = shop.toJsonForUpdate()
    return try? JSONSerialization.data(withJSONObject: json)
  }

  // MARK: - Parameters
  let id: String
  let shop: Shop

  // MARK: - Internal
  func handle(response: Data) throws -> Response {
    let json = try JSON(data: response)
    let doc = JSONAPIDocument(json)
    let shops = try doc.data.map { try ShopAdapter.process(resource: $0) }
    guard let shop = shops.first,
      shops.count == 1 else {
        throw NativeAppTemplateAPIError.responseHasIncorrectNumberOfElements
    }
    
    return shop
  }
}

struct DestroyShopRequest: Request {
  typealias Response = Void
  
  // MARK: - Properties
  var method: HTTPMethod { .DELETE }
  var path: String { "/shopkeeper/shops/\(id)" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? { nil }
  
  // MARK: - Parameters
  let id: String
  
  // MARK: - Internal
  func handle(response: Data) throws { }
}

struct ResetShopRequest: Request {
  typealias Response = Void
  
  // MARK: - Properties
  var method: HTTPMethod { .DELETE }
  var path: String { "/shopkeeper/shops/\(id)/reset" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? { nil }
  
  // MARK: - Parameters
  let id: String
  
  // MARK: - Internal
  func handle(response: Data) throws { }
}
