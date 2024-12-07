//
//  SignUpRequest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2022/07/07.
//

import Foundation
import SwiftyJSON

struct MakeShopkeeperRequest: Request {
  typealias Response = Shopkeeper

  // MARK: - Properties
  var method: HTTPMethod { .POST }
  var path: String { "/shopkeeper_auth" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? {
    let json = signUp.toJsonForCreate()
    return try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
  }
  
  // MARK: - Parameters
  let signUp: SignUp

  func handle(response: Data) throws -> Shopkeeper {
    let json = try JSON(data: response)
    let doc = JSONAPIDocument(json)
    let shopkeepers = try doc.data.map { try ShopkeeperSignInAdapter.process(resource: $0) }
    return shopkeepers.first!
  }
}

struct UpdateShopkeeperRequest: Request {
  typealias Response = Shopkeeper
  
  // MARK: - Properties
  var method: HTTPMethod { .PATCH }
  var path: String { "/shopkeeper_auth" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? {
    let json = signUp.toJsonForUpdate()
    return try? JSONSerialization.data(withJSONObject: json)
  }

  // MARK: - Parameters
  let id: String
  let signUp: SignUp

  // MARK: - Internal
  func handle(response: Data) throws -> Response {
    let json = try JSON(data: response)
    let doc = JSONAPIDocument(json)
    let shopkeepers = try doc.data.map { try ShopkeeperSignInAdapter.process(resource: $0) }
    guard let shopkeeper = shopkeepers.first,
      shopkeepers.count == 1 else {
        throw NativeAppTemplateAPIError.responseHasIncorrectNumberOfElements
    }
    
    return shopkeeper
  }
}

struct DestroyShopkeeperRequest: Request {
  typealias Response = Void
  
  // MARK: - Properties
  var method: HTTPMethod { .DELETE }
  var path: String { "/shopkeeper_auth" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? { nil }
    
  // MARK: - Internal
  func handle(response: Data) throws { }
}

struct SendResetPasswordInstructionRequest: Request {
  typealias Response = Void
  
  // MARK: - Properties
  var method: HTTPMethod { .POST }
  var path: String { "/shopkeeper_auth/password" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? {
    let json = sendResetPassword.toJson()
    return try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
  }

  // MARK: - Parameters
  let sendResetPassword: SendResetPassword

  // MARK: - Internal
  func handle(response: Data) throws { }
}

struct SendConfirmationInstructionRequest: Request {
  typealias Response = Void
  
  // MARK: - Properties
  var method: HTTPMethod { .POST }
  var path: String { "/shopkeeper_auth/confirmation" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? {
    let json = sendConfirmation.toJson()
    return try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
  }

  // MARK: - Parameters
  let sendConfirmation: SendConfirmation

  // MARK: - Internal
  func handle(response: Data) throws { }
}
