//
//  AccountPasswordRepository.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/25.
//

class AccountPasswordRepository {
  let accountPasswordService: AccountPasswordService
      
  init(
    accountPasswordService: AccountPasswordService
  ) {
    self.accountPasswordService = accountPasswordService
  }

  func update(updatePassword: UpdatePassword) async throws {
    do {
      try await accountPasswordService.updatePassword(updatePassword: updatePassword)
    } catch {
      Failure
        .destroy(from: Self.self, reason: error.localizedDescription)
        .log()
      throw error
    }
  }
}
