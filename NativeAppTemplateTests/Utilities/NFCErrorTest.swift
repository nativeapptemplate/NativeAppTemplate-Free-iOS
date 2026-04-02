//
//  NFCErrorTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

@Suite
struct NFCErrorTest {
    @Test
    func scanFailedErrorCode() {
        let error = NFCError.scanFailed("Tag not valid")
        #expect(error.errorCode == "NATI-3001")
    }

    @Test
    func scanFailedErrorDescription() {
        let error = NFCError.scanFailed("Tag not valid")
        #expect(error.errorDescription == "Tag not valid")
    }

    @Test
    func scanFailedFormattedDescription() {
        let error = NFCError.scanFailed("Tag not valid")
        #expect(error.formattedDescription == "[NATI-3001] Tag not valid")
    }

    @Test
    func codedDescriptionViaErrorExtension() {
        let error: Error = NFCError.scanFailed("Scan failed message")
        #expect(error.codedDescription == "[NATI-3001] Scan failed message")
    }
}
