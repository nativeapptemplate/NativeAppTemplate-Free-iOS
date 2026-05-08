//
//  KeychainStoreErrorTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Foundation
import Testing

@Suite
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
        #expect(
            KeychainStoreError.notFound.formattedDescription
                == "[NATIVEAPPTEMPLATE-4002] KeychainStoreError::NotFound"
        )
        #expect(
            KeychainStoreError.badData.formattedDescription
                == "[NATIVEAPPTEMPLATE-4003] KeychainStoreError::BadData"
        )
    }

    @Test
    func codedDescriptionPrependsCode() {
        let error: Error = KeychainStoreError.notFound

        #expect(error.codedDescription == "[NATIVEAPPTEMPLATE-4002] KeychainStoreError::NotFound")
    }
}
