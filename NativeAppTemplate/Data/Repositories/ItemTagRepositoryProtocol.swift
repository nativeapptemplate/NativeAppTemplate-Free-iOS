//
//  ItemTagRepositoryProtocol.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/01.
//

import SwiftUI

@MainActor protocol ItemTagRepositoryProtocol: AnyObject, Observable, Sendable {
  var itemTags: [ItemTag] { get set }
  var state: DataState { get set }
  var isEmpty: Bool { get }
  
  init(itemTagsService: ItemTagsService)
  
  func findBy(id: String) -> ItemTag
  func reload(shopId: String)
  func fetchAll(shopId: String) async throws -> [ItemTag]
  func fetchDetail(id: String) async throws -> ItemTag
  func create(shopId: String, itemTag: ItemTag) async throws -> ItemTag
  func update(id: String, itemTag: ItemTag) async throws -> ItemTag
  func destroy(id: String) async throws
  func complete(id: String) async throws -> ItemTag
  func reset(id: String) async throws -> ItemTag
}
