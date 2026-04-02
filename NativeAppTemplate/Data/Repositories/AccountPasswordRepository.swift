//
//  AccountPasswordRepository.swift
//  NativeAppTemplate
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
                .destroy(from: Self.self, reason: error.codedDescription)
                .log()
            throw error
        }
    }
}
