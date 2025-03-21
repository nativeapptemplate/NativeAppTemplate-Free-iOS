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

import struct Foundation.Data
import SwiftyJSON

struct PermissionsResponse {
  var iosAppVersion: Int
  var shouldUpdatePrivacy: Bool
  var shouldUpdateTerms: Bool
  var maximumQueueNumberLength: Int
  var shopLimitCount: Int
}

struct PermissionsRequest: Request {
  typealias Response = PermissionsResponse

  // MARK: - Properties
  var method: HTTPMethod { .GET }
  var path: String { "/shopkeeper/permissions" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? { nil }

  // MARK: - Internal
  func handle(response: Data) throws -> Response {
    let json = try JSON(data: response)
    let doc = JSONAPIDocument(json)

    guard let iosAppVersion = doc.meta["ios_app_version"] as? Int else {
      throw NativeAppTemplateAPIError.responseMissingRequiredMeta(field: "ios_app_version")
    }
    
    guard let shouldUpdatePrivacy = doc.meta["should_update_privacy"] as? Bool else {
      throw NativeAppTemplateAPIError.responseMissingRequiredMeta(field: "should_update_privacy")
    }

    guard let shouldUpdateTerms = doc.meta["should_update_terms"] as? Bool else {
      throw NativeAppTemplateAPIError.responseMissingRequiredMeta(field: "should_update_terms")
    }

    guard let maximumQueueNumberLength = doc.meta["maximum_queue_number_length"] as? Int else {
      throw NativeAppTemplateAPIError.responseMissingRequiredMeta(field: "maximum_queue_number_length")
    }

    guard let shopLimitCount = doc.meta["shop_limit_count"] as? Int else {
      throw NativeAppTemplateAPIError.responseMissingRequiredMeta(field: "shop_limit_count")
    }

    let prmissionsResponse = PermissionsResponse(
      iosAppVersion: iosAppVersion,
      shouldUpdatePrivacy: shouldUpdatePrivacy,
      shouldUpdateTerms: shouldUpdateTerms,
      maximumQueueNumberLength: maximumQueueNumberLength,
      shopLimitCount: shopLimitCount
    )

    return prmissionsResponse
  }
}
