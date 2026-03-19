//
//  StringExtensionsTest.swift
//  NativeAppTemplate
//

import CoreGraphics
@testable import NativeAppTemplate
import Testing

struct StringExtensionsTest {
    @Test(arguments: [
        ("hello123", true),
        ("ABC", true),
        ("abc", true),
        ("123", true),
        ("Hello World", false),
        ("hello!", false),
        ("hello@world", false),
        ("", false)
    ])
    func isAlphanumeric(input: String, expected: Bool) {
        #expect(input.isAlphanumeric() == expected)
    }

    @Test
    func isAlphanumericIgnoringDiacritics() {
        #expect("hello123".isAlphanumeric(ignoreDiacritics: true) == true)
        #expect("ABC123".isAlphanumeric(ignoreDiacritics: true) == true)
        #expect("hello world".isAlphanumeric(ignoreDiacritics: true) == false)
        #expect("".isAlphanumeric(ignoreDiacritics: true) == false)
    }

    @Test
    func imageGeneration() {
        let image = "A".image(size: CGSize(width: 50, height: 50))
        #expect(image != nil)
    }
}
