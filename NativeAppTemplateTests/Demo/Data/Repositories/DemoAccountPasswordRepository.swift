//
//  DemoAccountPasswordRepository.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/16.
//

@testable import NativeAppTemplate
import Foundation

@MainActor
final class DemoAccountPasswordRepository: AccountPasswordRepositoryProtocol {
  var lastUpdatePassword: UpdatePassword?
  var shouldThrowError = false
  var errorMessage = "Invalid current password"

  required init(accountPasswordService: AccountPasswordService) {
  }

  func update(updatePassword: UpdatePassword) async throws {
    lastUpdatePassword = updatePassword

    if shouldThrowError {
      throw NativeAppTemplateAPIError.requestFailed(nil, 422, errorMessage)
    }

    // Simulate validation
    if updatePassword.currentPassword.isEmpty {
      throw NativeAppTemplateAPIError.requestFailed(nil, 422, "Current password is required")
    }

    if updatePassword.password.isEmpty {
      throw NativeAppTemplateAPIError.requestFailed(nil, 422, "New password is required")
    }

    if updatePassword.password != updatePassword.passwordConfirmation {
      throw NativeAppTemplateAPIError.requestFailed(nil, 422, "Password confirmation does not match")
    }

    if updatePassword.password.count < 8 {
      throw NativeAppTemplateAPIError.requestFailed(nil, 422, "Password must be at least 8 characters long")
    }

    // Success case - password updated
  }

  // MARK: - Test Helpers
  func resetState() {
    lastUpdatePassword = nil
    shouldThrowError = false
    errorMessage = "Invalid current password"
  }
}
