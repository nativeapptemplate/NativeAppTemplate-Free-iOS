//
//  ShopRepositoryTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// ShopRepository with the real ShopsService and requests, against a local server.
/// Bodies follow ShopSerializer (name, description, time_zone, item_tags_count,
/// completed_item_tags_count) and ShopsController#index's meta (limit_count, created_shops_count).
@MainActor
@Suite(.serialized)
struct ShopRepositoryTest {
    private nonisolated static func shop(id: String, name: String = "Shop") -> [String: Any] {
        [
            "id": id,
            "type": "shop",
            "attributes": [
                "name": name,
                "description": "",
                "time_zone": "Tokyo",
                "item_tags_count": 3,
                "completed_item_tags_count": 1
            ] as [String: Any]
        ]
    }

    private func makeRepository(_ server: TestHTTPServer) -> ShopRepository {
        ShopRepository(shopsService: ShopsService(networkClient: server.client(accountId: "acc-1")))
    }

    @Test
    func reloadLoadsTheShopsAndTheLimits() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json([
                "data": [Self.shop(id: "s1", name: "First"), Self.shop(id: "s2", name: "Second")],
                "meta": ["limit_count": 5, "created_shops_count": 2]
            ])
        }
        defer { server.stop() }
        let repository = makeRepository(server)

        repository.reload()
        await waitUntil { repository.state != .loading }

        #expect(repository.state == .hasData)
        #expect(repository.shops.map(\.name) == ["First", "Second"])
        #expect(repository.shops.first?.itemTagsCount == 3)
        #expect(repository.shops.first?.completedItemTagsCount == 1)
        #expect(repository.limitCount == 5)
        #expect(repository.createdShopsCount == 2)
        #expect(server.requests.first?.method == "GET")
        #expect(server.requests.first?.path == "/acc-1/api/v1/shopkeeper/shops")
    }

    /// GetShopsRequest requires both meta fields; without them the whole reload fails
    @Test
    func reloadWithoutTheMetaFails() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json(["data": [Self.shop(id: "s1")], "meta": ["limit_count": 5]])
        }
        defer { server.stop() }
        let repository = makeRepository(server)

        repository.reload()
        await waitUntil { repository.state != .loading }

        #expect(repository.state == .failed)
        #expect(repository.shops.isEmpty)
    }

    /// fetchDetail upserts: appends a shop it does not have, replaces one it has
    @Test
    func fetchDetailAppendsOrReplaces() async throws {
        let server = try await TestHTTPServer.start { request in
            request.path.hasSuffix("/s1")
                ? TestHTTPServer.json(["data": Self.shop(id: "s1", name: "Renamed")])
                : TestHTTPServer.json(["data": Self.shop(id: "s9", name: "New")])
        }
        defer { server.stop() }
        let repository = makeRepository(server)
        repository.shops = [Shop(id: "s1", name: "Old", description: "", timeZone: "Tokyo")]

        _ = try await repository.fetchDetail(id: "s1")
        _ = try await repository.fetchDetail(id: "s9")

        #expect(repository.shops.map(\.id) == ["s1", "s9"])
        #expect(repository.shops.map(\.name) == ["Renamed", "New"])
    }

    /// create POSTs Shop.toJsonForCreate and returns the created shop, but does not
    /// add it to `shops` (ShopListView reloads after creating)
    @Test
    func createSendsTheShopAndLeavesTheListAlone() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json(status: 201, ["data": Self.shop(id: "s2", name: "Created")])
        }
        defer { server.stop() }
        let repository = makeRepository(server)
        repository.shops = [Shop(id: "s1", name: "Existing", description: "", timeZone: "Tokyo")]

        let created = try await repository.create(
            shop: Shop(id: "", name: "Created", description: "Desc", timeZone: "Osaka")
        )

        #expect(created.id == "s2")
        #expect(repository.shops.map(\.id) == ["s1"])
        let request = try #require(server.requests.first)
        #expect(request.method == "POST")
        #expect(request.path == "/acc-1/api/v1/shopkeeper/shops")
        let body = try #require(try JSONSerialization.jsonObject(with: request.body) as? [String: [String: String]])
        #expect(body == ["shop": ["name": "Created", "description": "Desc", "time_zone": "Osaka"]])
    }

    /// update replaces the shop in `shops` when it is there
    @Test
    func updateReplacesTheListedShop() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json(["data": Self.shop(id: "s1", name: "Updated")])
        }
        defer { server.stop() }
        let repository = makeRepository(server)
        repository.shops = [Shop(id: "s1", name: "Old", description: "", timeZone: "Tokyo")]

        _ = try await repository.update(
            id: "s1",
            shop: Shop(id: "s1", name: "Updated", description: "", timeZone: "Tokyo")
        )

        #expect(repository.shops.map(\.name) == ["Updated"])
        #expect(server.requests.first?.method == "PATCH")
        #expect(server.requests.first?.path == "/acc-1/api/v1/shopkeeper/shops/s1")
    }

    /// destroy sends DELETE but keeps `shops` as is (the list reloads afterwards)
    @Test
    func destroyLeavesTheListAlone() async throws {
        let server = try await TestHTTPServer.start { _ in TestHTTPServer.response(status: 204) }
        defer { server.stop() }
        let repository = makeRepository(server)
        repository.shops = [Shop(id: "s1", name: "Shop", description: "", timeZone: "Tokyo")]

        try await repository.destroy(id: "s1")

        #expect(server.requests.first?.method == "DELETE")
        #expect(server.requests.first?.path == "/acc-1/api/v1/shopkeeper/shops/s1")
        #expect(repository.shops.map(\.id) == ["s1"])
    }

    @Test
    func failedUpdateThrowsAndKeepsTheShop() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json(status: 422, ["error_message": "Name can't be blank"])
        }
        defer { server.stop() }
        let repository = makeRepository(server)
        repository.shops = [Shop(id: "s1", name: "Old", description: "", timeZone: "Tokyo")]

        let error = try await requestFailed {
            _ = try await repository.update(
                id: "s1",
                shop: Shop(id: "s1", name: "", description: "", timeZone: "Tokyo")
            )
        }

        guard case let .requestFailed(_, statusCode, message) = error else {
            Issue.record("Expected requestFailed, got \(error)")
            return
        }
        #expect(statusCode == 422)
        #expect(message == "Name can't be blank")
        #expect(repository.shops.map(\.name) == ["Old"])
    }
}
