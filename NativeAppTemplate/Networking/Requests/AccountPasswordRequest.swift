//
//  AccountPasswordRequest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/25.
//

import Foundation
import SwiftyJSON

struct UpdateAccountPasswordRequest: Request {
  typealias Response = Void
  
  // MARK: - Properties
  var method: HTTPMethod { .PATCH }
  var path: String { "/shopkeeper/account/password" }
  var additionalHeaders: [String: String] = [:]
  var body: Data? {
    let json = updatePassword.toJson()
    return try? JSONSerialization.data(withJSONObject: json)
  }

  let updatePassword: UpdatePassword

  // MARK: - Internal
  func handle(response: Data) throws { }
}
