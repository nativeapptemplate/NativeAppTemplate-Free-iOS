//
//  DataCacheUpdate.swift
//  NativeAppTemplate
//

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
            .filter { $0.type == "shop" }
            .map { try ShopAdapter.process(resource: $0, relationships: relationships) }
        shopkeepers = try resources
            .filter { $0.type == "shopkeeper" }
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
