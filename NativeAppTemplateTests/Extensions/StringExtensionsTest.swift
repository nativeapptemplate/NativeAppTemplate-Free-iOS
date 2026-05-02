//
//  StringExtensionsTest.swift
//  NativeAppTemplate
//

@testable import NativeAppTemplate
import Testing

struct StringExtensionsTest {
    @Test(arguments: [
        ("", true),
        ("   ", true),
        ("\n", true),
        (" \t\n ", true),
        ("hello", false),
        (" hello ", false),
    ])
    func isBlank(text: String, expected: Bool) {
        #expect(text.isBlank == expected)
    }

    @Test(arguments: [
        ("test@example.com", true),
        ("user.name+tag@domain.co", true),
        ("user@domain.com", true),
        ("", false),
        ("notanemail", false),
        ("@domain.com", false),
        ("user@", false),
        ("user@.com", false),
    ])
    func isValidEmail(email: String, expected: Bool) {
        #expect(email.isValidEmail == expected)
    }
}
