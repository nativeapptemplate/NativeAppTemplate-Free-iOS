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

import Foundation

protocol EntityAdapter {
  associatedtype Response
  
  static func process(resource: JSONAPIResource, relationships: [EntityRelationship], cacheUpdate: DataCacheUpdate) throws -> Response
}

enum EntityType {
  case shop
  case shopkeeper
  case shopkeeperSignIn

  init?(from string: String) {
    switch string {
    case "shop":
      self = .shop
    case "shopkeeper":
      self = .shopkeeper
    case "shopkeeper_sign_in":
      self = .shopkeeperSignIn
    default:
      return nil
    }
  }
}

struct EntityIdentity: Identifiable {
  let id: String
  let type: EntityType
}

struct EntityRelationship {
  let name: String
  let from: EntityIdentity
  let to: EntityIdentity // swiftlint:disable:this identifier_name
}

enum EntityAdapterError: Error {
  case invalidResourceTypeForAdapter
  case invalidOrMissingAttributes
  case invalidOrMissingRelationships
}

extension EntityAdapterError: LocalizedError {
  var errorDescription: String? {
    let prefix = "EntityAdapterError::"
    switch self {
    case .invalidResourceTypeForAdapter:
      return "\(prefix)InvalidResourceTypeForAdapter"
    case .invalidOrMissingAttributes:
      return "\(prefix)InvalidOrMissingAttributes"
    case .invalidOrMissingRelationships:
      return "\(prefix)InvalidOrMissingRelationships"
    }
  }
}
