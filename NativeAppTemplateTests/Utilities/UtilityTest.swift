//
//  UtilityTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

struct UtilityTest {
    @Test(arguments: [
        ("", true),
        ("   ", true),
        ("\n", true),
        (" \t\n ", true),
        ("hello", false),
        (" hello ", false)
    ])
    func isBlank(text: String, expected: Bool) {
        #expect(Utility.isBlank(text) == expected)
    }

    @Test(arguments: [
        ("test@example.com", true),
        ("user.name+tag@domain.co", true),
        ("user@domain.com", true),
        ("", false),
        ("notanemail", false),
        ("@domain.com", false),
        ("user@", false),
        ("user@.com", false)
    ])
    func validateEmail(email: String, expected: Bool) {
        #expect(Utility.validateEmail(email) == expected)
    }

}
