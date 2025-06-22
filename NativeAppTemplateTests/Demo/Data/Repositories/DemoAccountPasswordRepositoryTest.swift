//
//  DemoAccountPasswordRepositoryTest.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2025/06/16.
//

import Testing
@testable import NativeAppTemplate

@Suite
struct DemoAccountPasswordRepositoryTest {
  @MainActor
  struct Tests {
    let repository = DemoAccountPasswordRepository(accountPasswordService: AccountPasswordService())

    @Test
    func updatePasswordSuccess() async throws {
      repository.resetState()

      let updatePassword = UpdatePassword(
        currentPassword: "currentPassword123",
        password: "newPassword123",
        passwordConfirmation: "newPassword123"
      )

      await #expect(throws: Never.self) {
        try await repository.update(updatePassword: updatePassword)
      }

      #expect(repository.lastUpdatePassword?.currentPassword == "currentPassword123")
      #expect(repository.lastUpdatePassword?.password == "newPassword123")
      #expect(repository.lastUpdatePassword?.passwordConfirmation == "newPassword123")
    }

    @Test
    func updatePasswordWithEmptyCurrentPassword() async throws {
      repository.resetState()

      let updatePassword = UpdatePassword(
        currentPassword: "",
        password: "newPassword123",
        passwordConfirmation: "newPassword123"
      )

      await #expect(throws: NativeAppTemplateAPIError.self) {
        try await repository.update(updatePassword: updatePassword)
      }
    }

    @Test
    func updatePasswordWithEmptyNewPassword() async throws {
      repository.resetState()

      let updatePassword = UpdatePassword(
        currentPassword: "currentPassword123",
        password: "",
        passwordConfirmation: ""
      )

      await #expect(throws: NativeAppTemplateAPIError.self) {
        try await repository.update(updatePassword: updatePassword)
      }
    }

    @Test
    func updatePasswordWithMismatchedConfirmation() async throws {
      repository.resetState()

      let updatePassword = UpdatePassword(
        currentPassword: "currentPassword123",
        password: "newPassword123",
        passwordConfirmation: "differentPassword123"
      )

      await #expect(throws: NativeAppTemplateAPIError.self) {
        try await repository.update(updatePassword: updatePassword)
      }
    }

    @Test
    func updatePasswordWithShortPassword() async throws {
      repository.resetState()

      let updatePassword = UpdatePassword(
        currentPassword: "currentPassword123",
        password: "short",
        passwordConfirmation: "short"
      )

      await #expect(throws: NativeAppTemplateAPIError.self) {
        try await repository.update(updatePassword: updatePassword)
      }
    }

    @Test
    func updatePasswordWithForcedError() async throws {
      repository.resetState()
      repository.shouldThrowError = true
      repository.errorMessage = "Custom error message"

      let updatePassword = UpdatePassword(
        currentPassword: "currentPassword123",
        password: "newPassword123",
        passwordConfirmation: "newPassword123"
      )

      await #expect(throws: NativeAppTemplateAPIError.self) {
        try await repository.update(updatePassword: updatePassword)
      }
    }
  }
}
