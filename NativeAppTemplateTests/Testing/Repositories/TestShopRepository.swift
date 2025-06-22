//
//  TestShopRepository.swift
//  NativeAppTemplate
//
//  Created by Claude on 2025/06/22.
//

import Foundation
@testable import NativeAppTemplate

@MainActor
final class TestShopRepository: ShopRepositoryProtocol {
  var shops: [Shop] = []
  var state: DataState = .initial
  var limitCount: Int = 0
  var createdShopsCount: Int = 0
  var isEmpty: Bool { shops.isEmpty }

  // A test-only
  var error: NativeAppTemplateAPIError?

  required init(shopsService: ShopsService) {
    createdShopsCount = shops.count
  }

  func findBy(id: String) -> Shop {
    guard let shop = shops.first(where: { $0.id == id }) else {
      fatalError("Test setup error: Shop with id '\(id)' not found. Available IDs: \(shops.map { $0.id })")
    }
    return shop
  }

  func reload() {
    guard error == nil else {
      state = .failed
      return
    }

    state = .loading
    createdShopsCount = shops.count
    state = .hasData
  }

  func fetchDetail(id: String) async throws -> Shop {
    guard error == nil else {
      throw error!
    }

    guard let shop = shops.first(where: { $0.id == id }) else {
      throw NativeAppTemplateAPIError.requestFailed(nil, 404, "Shop with id '\(id)' not found")
    }
    return shop
  }

  func create(shop: Shop) async throws -> Shop {
    guard error == nil else {
      throw error!
    }

    shops.append(shop)
    createdShopsCount += 1
    return shop
  }

  func update(id: String, shop: Shop) async throws -> Shop {
    guard error == nil else {
      throw error!
    }

    if let index = shops.firstIndex(where: { $0.id == id }) {
      shops[index] = shop
    }
    return shop
  }

  func destroy(id: String) async throws {
    guard error == nil else {
      throw error!
    }

    shops.removeAll { $0.id == id }
  }

  func reset(id: String) async throws {
    guard error == nil else {
      throw error!
    }
  }

  // A test-only
  func setShops(shops: [Shop]) {
    self.shops = shops
    createdShopsCount = shops.count
  }
}
