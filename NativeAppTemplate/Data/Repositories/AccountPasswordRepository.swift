//
//  AccountPasswordRepository.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/25.
//

@MainActor class AccountPasswordRepository: AccountPasswordRepositoryProtocol {
  let accountPasswordService: AccountPasswordService
      
  required init(
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
