//
//  AccountPasswordRepositoryTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

/// AccountPasswordRepository with the real AccountPasswordService and
/// UpdateAccountPasswordRequest, against a local server
@MainActor
@Suite(.serialized)
struct AccountPasswordRepositoryTest {
    private let updatePassword = UpdatePassword(
        currentPassword: "current-password",
        password: "new-password",
        passwordConfirmation: "new-password"
    )

    private func makeRepository(_ server: TestHTTPServer) -> AccountPasswordRepository {
        AccountPasswordRepository(
            accountPasswordService: AccountPasswordService(networkClient: server.client(accountId: "acc-1"))
        )
    }

    /// UpdateAccountPasswordRequest: PATCH /shopkeeper/account/password under Service's
    /// /{accountId}/api/v1, with UpdatePassword.toJson's body
    @Test
    func updatePatchesThePasswordWithTheSession() async throws {
        let server = try await TestHTTPServer.start { _ in TestHTTPServer.json([String: Any]()) }
        defer { server.stop() }

        try await makeRepository(server).update(updatePassword: updatePassword)

        let request = try #require(server.requests.first)
        #expect(server.requests.count == 1)
        #expect(request.method == "PATCH")
        #expect(request.path == "/acc-1/api/v1/shopkeeper/account/password")
        // The value TestHTTPServer.client sets
        #expect(request.headers["access-token"] == "token")
        let body = try #require(try JSONSerialization.jsonObject(with: request.body) as? [String: [String: String]])
        #expect(body == ["shopkeeper": [
            "current_password": "current-password",
            "password": "new-password",
            "password_confirmation": "new-password"
        ]])
    }

    /// The API's error reaches the caller (PasswordEditViewModel shows it)
    @Test
    func failedUpdateThrowsTheAPIError() async throws {
        let server = try await TestHTTPServer.start { _ in
            TestHTTPServer.json(status: 422, ["error_message": "Current password is invalid"])
        }
        defer { server.stop() }

        let error = try await requestFailed {
            try await makeRepository(server).update(updatePassword: updatePassword)
        }

        guard case let .requestFailed(_, statusCode, message) = error else {
            Issue.record("Expected requestFailed, got \(error)")
            return
        }
        #expect(statusCode == 422)
        #expect(message == "Current password is invalid")
    }
}
