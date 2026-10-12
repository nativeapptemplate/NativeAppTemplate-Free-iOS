//
//  SessionControllerTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import OSLog
import Testing

@MainActor
@Suite(.serialized)
struct SessionControllerTest {
    /// A failed sign-out is logged as Failure.logout ("Failed_logout"), not as a
    /// sign-in failure. Failure.log writes
    /// "Failed_\(action) source=\(source) reason=\(reason)" to appLogger
    /// (subsystem com.nativeapptemplate), which this process can read back.
    @Test
    func failedLogoutIsLoggedAsALogoutFailure() async throws {
        let loginRepository = TestLoginRepository()
        loginRepository.logoutError = KeychainStoreError.badData
        let sessionController = SessionController(loginRepository: loginRepository)
        let start = Date.now.addingTimeInterval(-1)

        await #expect(throws: KeychainStoreError.self) {
            try await sessionController.logout()
        }

        let store = try OSLogStore(scope: .currentProcessIdentifier)
        let messages = try store
            .getEntries(
                at: store.position(date: start),
                matching: NSPredicate(format: "subsystem == %@", "com.nativeapptemplate")
            )
            .compactMap { ($0 as? OSLogEntryLog)?.composedMessage }
            .filter { $0.contains("source=SessionController ") }

        #expect(messages.contains { $0.hasPrefix("Failed_logout ") })
        #expect(!messages.contains { $0.hasPrefix("Failed_login ") })
        // The session is still cleared
        #expect(sessionController.userState == .notLoggedIn)
    }
}
