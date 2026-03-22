//
//  ShopsService.swift
//  NativeAppTemplate
//

struct ShopsService: Service {
    var networkClient = NativeAppTemplateAPI()
}

// MARK: - Internal

extension ShopsService {
    func allShops() async throws -> GetShopsRequest.Response {
        try await makeRequest(request: GetShopsRequest())
    }

    func updateShop(id: String, shop: Shop) async throws -> UpdateShopRequest.Response {
        let request = UpdateShopRequest(id: id, shop: shop)
        return try await makeRequest(request: request)
    }

    func destroyShop(id: String) async throws -> DestroyShopRequest.Response {
        try await makeRequest(request: DestroyShopRequest(id: id))
    }

    func shopDetail(id: String) async throws -> GetShopDetailRequest.Response {
        try await makeRequest(request: GetShopDetailRequest(id: id))
    }

    func makeShop(shop: Shop) async throws -> MakeShopRequest.Response {
        let request = MakeShopRequest(shop: shop)
        return try await makeRequest(request: request)
    }

    func resetShop(id: String) async throws -> ResetShopRequest.Response {
        try await makeRequest(request: ResetShopRequest(id: id))
    }
}
