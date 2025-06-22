//
//  DemoShopRepositoryTests.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/05/11.
//

import Testing
@testable import NativeAppTemplate

@Suite
struct DemoShopRepositoryTest {
  @MainActor
  struct Tests {
    let repository = DemoShopRepository(shopsService: ShopsService())

    @Test
    func findBy() {
      repository.reload()

      let shop = repository.findBy(id: "1")
      #expect(shop.name == "Shop 1")
    }

    @Test
    func reload() {
      repository.reload()

      #expect(repository.shops.count == 5)
      #expect(repository.state == .hasData)
    }

    @Test
    func fetchDetail() async throws {
      repository.reload()

      let shop = try await repository.fetchDetail(id: "1")
      #expect(shop.name == "Shop 1")
    }

    @Test
    func create() async throws {
      repository.reload()

      let newName = "New Shop"
      let newShop = Shop(
        id: "99",
        name: newName,
        description: "A new shop",
        timeZone: "Tokyo",
        itemTagsCount: 0,
        scannedItemTagsCount: 0,
        completedItemTagsCount: 0,
        displayShopServerPath: "https://api.nativeapptemplate.com/display/shops/99?type=server"
      )

      let createdShop = try await repository.create(shop: newShop)
      #expect(createdShop.name == newName)
      #expect(repository.shops.count == 6)
    }

    @Test
    func update() async throws {
      repository.reload()

      var shop = repository.findBy(id: "1")
      let newName = "New Shop"
      shop.name = newName
      let updatedShop = try await repository.update(id: "1", shop: shop)
      #expect(updatedShop.name == newName)
    }

    @Test
    func destroy() async throws {
      repository.reload()

      try await repository.destroy(id: "1")
      #expect(!repository.shops.contains { $0.id == "1" })
    }

    @Test
    func reset() async throws {
      repository.reload()

      await #expect(throws: Never.self) {
        try await repository.reset(id: "1")
      }
    }
  }
}
