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
        #expect(error.errorCode == "NATIVEAPPTEMPLATE-1001")
    }

    @Test
    func unexpectedErrorDescription() {
        let error = AppError.unexpected(description: "Something broke")
        #expect(error.errorDescription == "An unexpected error occurred. Something broke")
    }

    @Test
    func unexpectedFormattedDescription() {
        let error = AppError.unexpected(description: "Something broke")
        #expect(error.formattedDescription == "[NATIVEAPPTEMPLATE-1001] An unexpected error occurred. Something broke")
    }

    @Test
    func unexpectedDebugDescription() {
        let error = AppError.unexpected(
            description: "Something broke",
            file: "TestFile.swift",
            line: 42,
            function: "testFunc()"
        )
        #expect(error.debugDescription.contains("NATIVEAPPTEMPLATE-1001"))
        #expect(error.debugDescription.contains("Something broke"))
        #expect(error.debugDescription.contains("TestFile.swift"))
        #expect(error.debugDescription.contains("42"))
        #expect(error.debugDescription.contains("testFunc()"))
    }

    @Test
    func codedDescriptionViaErrorExtension() {
        let error: Error = AppError.unexpected(description: "Test")
        #expect(error.codedDescription == "[NATIVEAPPTEMPLATE-1001] An unexpected error occurred. Test")
    }
}
