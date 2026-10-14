//
//  KeychainStoreErrorTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Foundation
import Testing

struct KeychainStoreErrorTest {
    @Test
    func errorCodes() {
        let underlying = NSError(domain: "test", code: 1)

        #expect(KeychainStoreError.secCallFailed(underlying).errorCode == "NATIVEAPPTEMPLATE-4001")
        #expect(KeychainStoreError.notFound.errorCode == "NATIVEAPPTEMPLATE-4002")
        #expect(KeychainStoreError.badData.errorCode == "NATIVEAPPTEMPLATE-4003")
        #expect(KeychainStoreError.archiveFailure(underlying).errorCode == "NATIVEAPPTEMPLATE-4004")
    }

    @Test
    func formattedDescriptions() {
        // The generic text for developer-only errors, worded as decided for iOS and Android (2026-10-14)
        #expect(
            KeychainStoreError.notFound.formattedDescription
                == "[NATIVEAPPTEMPLATE-4002] An unexpected error occurred."
        )
        #expect(
            KeychainStoreError.badData.formattedDescription
                == "[NATIVEAPPTEMPLATE-4003] An unexpected error occurred."
        )
        #expect(
            KeychainStoreError.secCallFailed(NSError(domain: "test", code: 1)).formattedDescription
                == "[NATIVEAPPTEMPLATE-4001] An unexpected error occurred."
        )
    }

    @Test
    func codedDescriptionPrependsCode() {
        let error: Error = KeychainStoreError.notFound

        #expect(error.codedDescription == "[NATIVEAPPTEMPLATE-4002] An unexpected error occurred.")
    }

    /// The log keeps the case and the underlying error
    @Test
    func debugDescriptionKeepsTheUnderlyingError() {
        let error = KeychainStoreError.archiveFailure(NSError(domain: "test", code: 7))

        #expect(error.debugDescription.hasPrefix("[NATIVEAPPTEMPLATE-4004] KeychainStoreError::ArchiveFailure"))
        // NSError's localizedDescription names the domain and code: "The operation couldn’t be completed. (test error 7.)"
        #expect(error.debugDescription.contains("test error 7"))
    }
}
