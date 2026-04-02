//
//  AppErrorTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

@Suite
struct AppErrorTest {
    @Test
    func unexpectedErrorCode() {
        let error = AppError.unexpected(description: "Something broke")
        #expect(error.errorCode == "NATI-1001")
    }

    @Test
    func unexpectedErrorDescription() {
        let error = AppError.unexpected(description: "Something broke")
        #expect(error.errorDescription == "An unexpected error occurred. Something broke")
    }

    @Test
    func unexpectedFormattedDescription() {
        let error = AppError.unexpected(description: "Something broke")
        #expect(error.formattedDescription == "[NATI-1001] An unexpected error occurred. Something broke")
    }

    @Test
    func unexpectedDebugDescription() {
        let error = AppError.unexpected(
            description: "Something broke",
            file: "TestFile.swift",
            line: 42,
            function: "testFunc()"
        )
        #expect(error.debugDescription.contains("NATI-1001"))
        #expect(error.debugDescription.contains("Something broke"))
        #expect(error.debugDescription.contains("TestFile.swift"))
        #expect(error.debugDescription.contains("42"))
        #expect(error.debugDescription.contains("testFunc()"))
    }

    @Test
    func codedDescriptionViaErrorExtension() {
        let error: Error = AppError.unexpected(description: "Test")
        #expect(error.codedDescription == "[NATI-1001] An unexpected error occurred. Test")
    }
}
