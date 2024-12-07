// Copyright (c) 2022 Razeware LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

typealias JSONEntityRelationships = (entity: EntityIdentity?, jsonRelationships: [JSONAPIRelationship])

struct DataCacheUpdate {
  let shops: [Shop]
  let shopkeepers: [Shopkeeper]
  let relationships: [EntityRelationship]
  
  static func loadFrom(document: JSONAPIDocument) throws -> DataCacheUpdate {
    let data = try DataCacheUpdate(resources: document.data)
    let included = try DataCacheUpdate(
      resources: document.included,
      relationships: document.data.map { (entity: $0.entityID, $0.relationships) }
    )
    return data.merged(with: included)
  }
  
  init(
    shops: [Shop] = [],
    shopkeepers: [Shopkeeper] = [],
    relationships: [EntityRelationship] = []
  ) {
    self.shops = shops
    self.shopkeepers = shopkeepers
    self.relationships = relationships
  }
  
  init(resources: [JSONAPIResource], relationships jsonEntityRelationships: [JSONEntityRelationships] = []) throws {
    let relationships = DataCacheUpdate.relationships(from: resources, with: jsonEntityRelationships)
    shops = try resources
      .filter({ $0.type == "shop" })
      .map { try ShopAdapter.process(resource: $0, relationships: relationships) }
    shopkeepers = try resources
      .filter({ $0.type == "shopkeeper" })
      .map { try ShopkeeperAdapter.process(resource: $0, relationships: relationships) }
    self.relationships = relationships
  }
  
  func merged(with other: DataCacheUpdate) -> DataCacheUpdate {
    .init(
      shops: shops + other.shops,
      shopkeepers: shopkeepers + other.shopkeepers,
      relationships: relationships + other.relationships
    )
  }
  
  private static func relationships(
    from resources: [JSONAPIResource],
    with additionalRelationships: [JSONEntityRelationships]
  ) -> [EntityRelationship] {
    var relationshipsToReturn = additionalRelationships.flatMap { entityRelationship -> [EntityRelationship] in
      guard let entityID = entityRelationship.entity else { return [] }
      return entityRelationships(from: entityRelationship.jsonRelationships, fromEntity: entityID)
    }
    relationshipsToReturn += resources.flatMap { resource -> [EntityRelationship] in
      guard let resourceEntityID = resource.entityID else { return [] }
      return entityRelationships(from: resource.relationships, fromEntity: resourceEntityID)
    }
    return relationshipsToReturn
  }
  
  private static func entityRelationships(
    from jsonRelationships: [JSONAPIRelationship],
    fromEntity: EntityIdentity
  ) -> [EntityRelationship] {
    jsonRelationships.flatMap { relationship in
      relationship.data.compactMap { resource in
        guard let toEntity = resource.entityID else { return nil }
        return EntityRelationship(
          name: relationship.type,
          from: fromEntity,
          to: toEntity
        )
      }
    }
  }
}
