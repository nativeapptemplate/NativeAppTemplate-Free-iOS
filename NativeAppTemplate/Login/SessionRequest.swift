//
//  SessionRequest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2021/01/11.
//

import Foundation
import SwiftyJSON

struct MakeSessionRequest: Request {
  typealias Response = Shopkeeper

  // MARK: - Properties
  var method: HTTPMethod { .POST }
  var path: String { "/shopkeeper_auth/sign_in" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? {
    let json: [String: Any] = ["email": email, "password": password]
    return try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
  }
  
  // MARK: - Parameters
  let email: String
  let password: String

  func handle(response: Data) throws -> Shopkeeper {
    let json = try JSON(data: response)
    let doc = JSONAPIDocument(json)
    let shopkeepers = try doc.data.map { try ShopkeeperSignInAdapter.process(resource: $0) }
    return shopkeepers.first!
  }
}

struct DestroySessionRequest: Request {
  typealias Response = Void
  
  // MARK: - Properties
  var method: HTTPMethod { .DELETE }
  var path: String { "/shopkeeper_auth/sign_out" }
  var additionalHeaders: [String: String] = [:]

  var body: Data? { nil }

  // MARK: - Internal
  func handle(response: Data) throws { }
}
