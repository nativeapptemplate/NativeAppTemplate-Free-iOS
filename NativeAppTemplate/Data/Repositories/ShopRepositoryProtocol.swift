//
//  ShopRepositoryProtocol.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2022/06/28.
//

import SwiftUI

@MainActor protocol ShopRepositoryProtocol: AnyObject, Observable, Sendable {
  var shops: [Shop] { get }
  var isEmpty: Bool { get }
  var state: DataState { get }
  var limitCount: Int { get }
  var createdShopsCount: Int { get }
  
  init(shopsService: ShopsService)
  
  func findBy(id: String) -> Shop
  func reload()
  func fetchDetail(id: String) async throws -> Shop
  func create(shop: Shop) async throws -> Shop
  func update(id: String, shop: Shop) async throws -> Shop
  func destroy(id: String) async throws
  func reset(id: String) async throws
}
