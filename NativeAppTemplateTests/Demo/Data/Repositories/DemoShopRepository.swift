//
//  DemoShopRepository.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/05/11.
//

@testable import NativeAppTemplate
import Foundation

@MainActor
final class DemoShopRepository: ShopRepositoryProtocol {
  var shops: [Shop] = []
  var state: DataState = .initial
  var limitCount: Int = 10
  var createdShopsCount: Int = 0
  var isEmpty: Bool { shops.isEmpty }

  required init(shopsService: ShopsService) {
  }

  func findBy(id: String) -> Shop {
    shops.first { $0.id == id }!
  }

  func reload() {
    state = .loading
    shops = [
      mockShop(id: "1", name: "Shop 1"),
      mockShop(id: "2", name: "Shop 2"),
      mockShop(id: "3", name: "Shop 3"),
      mockShop(id: "4", name: "Shop 4"),
      mockShop(id: "5", name: "Shop 5")
     ]
    createdShopsCount = shops.count
    state = .hasData
  }

  func fetchDetail(id: String) async throws -> Shop {
    return shops.first { $0.id == id }!
  }

  func create(shop: Shop) async throws -> Shop {
    shops.append(shop)
    createdShopsCount += 1
    return shop
  }

  func update(id: String, shop: Shop) async throws -> Shop {
    let index = shops.firstIndex { $0.id == id }!
    shops[index] = shop

    return shop
  }

  func destroy(id: String) async throws {
    shops.removeAll { $0.id == id }
  }

  func reset(id: String) async throws {
  }

  // MARK: - Helpers
  private func mockShop(id: String = UUID().uuidString, name: String = "Mock Shop") -> Shop {
    Shop(
      id: id,
      name: name,
      description: "This is a mock shop for testing",
      timeZone: "Tokyo",
      itemTagsCount: 10,
      scannedItemTagsCount: 5,
      completedItemTagsCount: 3,
      displayShopServerPath: "https://api.nativeapptemplate.com/display/shops/\(id)?type=server"
    )
  }
}
