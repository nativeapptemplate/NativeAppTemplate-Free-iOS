//
//  AccountPasswordService.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/25.
//

import class Foundation.URLSession

struct AccountPasswordService: Service {
  var networkClient = NativeAppTemplateAPI()
  let session = URLSession(configuration: .default)
}

extension AccountPasswordService {
  func updatePassword(updatePassword: UpdatePassword) async throws -> UpdateAccountPasswordRequest.Response {
    let request = UpdateAccountPasswordRequest(updatePassword: updatePassword)
    return try await makeRequest(request: request)
  }
}
