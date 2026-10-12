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
    /// A test-only: when set, the save and delete calls wait here until the test opens it
    var gate: TestGate?
    var updateCalled = false
    var lastUpdatePassword: UpdatePassword?

    required init(accountPasswordService: AccountPasswordService) {}

    func update(updatePassword: UpdatePassword) async throws {
        await gate?.wait()
        updateCalled = true
        lastUpdatePassword = updatePassword

        guard error == nil else {
            throw error!
        }
    }
}
