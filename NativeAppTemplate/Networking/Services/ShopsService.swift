// Copyright (c) 2019 Razeware LLC
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

import class Foundation.URLSession

struct ShopsService: Service {
  let networkClient: NativeAppTemplateAPI
  let session = URLSession(configuration: .default)
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
