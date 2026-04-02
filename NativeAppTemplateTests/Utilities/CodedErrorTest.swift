//
//  CodedErrorTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

@Suite
struct CodedErrorTest {
    struct TestCodedError: CodedError {
        var errorCode: String { "NATI-9999" }
        var errorDescription: String? { "Test error description" }
    }

    @Test
    func formattedDescription() {
        let error = TestCodedError()
        #expect(error.formattedDescription == "[NATI-9999] Test error description")
    }

    @Test
    func codedDescriptionWithCodedError() {
        let error: Error = TestCodedError()
        #expect(error.codedDescription == "[NATI-9999] Test error description")
    }

    @Test
    func codedDescriptionWithNonCodedError() {
        let error: Error = NSError(
            domain: "TestDomain",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Plain error"]
        )
        #expect(error.codedDescription == "Plain error")
    }

    struct NilDescriptionError: CodedError {
        var errorCode: String { "NATI-0000" }
        var errorDescription: String? { nil }
    }

    @Test
    func formattedDescriptionWithNilErrorDescription() {
        let error = NilDescriptionError()
        #expect(error.formattedDescription == "[NATI-0000] Unknown error")
    }
}
