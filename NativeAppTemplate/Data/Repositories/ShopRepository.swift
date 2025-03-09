//
//  ShopRepository.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2022/06/28.
//

import SwiftUI

@MainActor @Observable class ShopRepository {
  let shopsService: ShopsService
  
  var shops: [Shop] = []
  private(set) var state: DataState = .initial
  private(set) var limitCount = 0
  private(set) var createdShopsCount = 0
  
  init(
    shopsService: ShopsService
  ) {
    self.shopsService = shopsService
  }
  
  var isEmpty: Bool { shops.isEmpty }
  
  func findBy(id: String) -> Shop {
    let shop = shops.first { $0.id == id }
    return shop!
  }
  
  func reload() {
    if Task.isCancelled {
      return
    }
    
    if state == .loading {
      return
    }
    
    state = .loading
    
    Task { @MainActor in
      do {
        (shops, limitCount, createdShopsCount) = try await shopsService.allShops()
        state = .hasData
      } catch {
        state = .failed
        Failure
          .fetch(from: Self.self, reason: error.localizedDescription)
          .log()
      }
    }
  }
  
  func fetchDetail(id: String) async throws -> Shop {
    do {
      let shop = try await shopsService.shopDetail(id: id)
      let shopIndex = (shops.firstIndex { $0.id == shop.id })
      if shopIndex != nil {
        shops[shopIndex!] = shop
      }
      
      return shop
    } catch {
      Failure
        .fetch(from: Self.self, reason: error.localizedDescription)
        .log()
      throw error
    }
  }
  
  func create(shop: Shop) async throws -> Shop {
    do {
      let createdShop = try await shopsService.makeShop(shop: shop)
      return createdShop
    } catch {
      Failure
        .create(from: Self.self, reason: error.localizedDescription)
        .log()
      throw error
    }
  }
  
  func update(id: String, shop: Shop) async throws -> Shop {
    do {
      let updatedShop = try await shopsService.updateShop(id: id, shop: shop)
      let shopIndex = (shops.firstIndex { $0.id == updatedShop.id })
      if shopIndex != nil {
        shops[shopIndex!] = updatedShop
      }
      
      return updatedShop
    } catch {
      Failure
        .update(from: Self.self, reason: error.localizedDescription)
        .log()
      throw error
    }
  }
  
  func destroy(id: String) async throws {
    do {
      try await shopsService.destroyShop(id: id)
    } catch {
      Failure
        .destroy(from: Self.self, reason: error.localizedDescription)
        .log()
      throw error
    }
  }
  
  func reset(id: String) async throws {
    do {
      try await shopsService.resetShop(id: id)
    } catch {
      Failure
        .destroy(from: Self.self, reason: error.localizedDescription)
        .log()
      throw error
    }
  }
}
