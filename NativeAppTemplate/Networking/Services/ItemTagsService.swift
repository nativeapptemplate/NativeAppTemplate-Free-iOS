//
//  ItemTagsService.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/03/01.
//

import class Foundation.URLSession

struct ItemTagsService: Service {
  var networkClient = NativeAppTemplateAPI()
  let session = URLSession(configuration: .default)
}

extension ItemTagsService {
  // MARK: - Internal
  func allItemTags(shopId: String) async throws -> GetItemTagsRequest.Response {
    let request = GetItemTagsRequest(shopId: shopId)
    return try await makeRequest(request: request)
  }
  
  func itemTagDetail(id: String) async throws -> GetItemTagDetailRequest.Response {
    try await makeRequest(request: GetItemTagDetailRequest(id: id))
  }
  
  func makeItemTag(shopId: String, itemTag: ItemTag) async throws -> MakeItemTagRequest.Response {
    let request = MakeItemTagRequest(shopId: shopId, itemTag: itemTag)
    return try await makeRequest(request: request)
  }
  
  func updateItemTag(id: String, itemTag: ItemTag) async throws -> UpdateItemTagRequest.Response {
    let request = UpdateItemTagRequest(id: id, itemTag: itemTag)
    return try await makeRequest(request: request)
  }
  
  func destroyItemTag(id: String) async throws -> DestroyItemTagRequest.Response {
    try await makeRequest(request: DestroyItemTagRequest(id: id))
  }
  
  func completeItemTag(id: String) async throws -> CompleteItemTagRequest.Response {
    try await makeRequest(request: CompleteItemTagRequest(id: id))
  }
  
  func resetItemTag(id: String) async throws -> ResetItemTagRequest.Response {
    try await makeRequest(request: ResetItemTagRequest(id: id))
  }
}
