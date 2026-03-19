//
//  TestAccountPasswordRepository.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate

@MainActor
final class TestAccountPasswordRepository: AccountPasswordRepositoryProtocol {
    // A test-only
    var error: NativeAppTemplateAPIError?
    var updateCalled = false
    var lastUpdatePassword: UpdatePassword?

    required init(accountPasswordService: AccountPasswordService) {}

    func update(updatePassword: UpdatePassword) async throws {
        updateCalled = true
        lastUpdatePassword = updatePassword

        guard error == nil else {
            throw error!
        }
    }
}
