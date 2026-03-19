//
//  UtilityTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

struct UtilityTest {
    @Test
    func scanUrlContainsExpectedParams() {
        let url = Utility.scanUrl(itemTagId: "abc-123", itemTagType: "server")

        #expect(url.absoluteString.contains("item_tag_id=abc-123"))
        #expect(url.absoluteString.contains("type=server"))
    }

    @Test
    func scanUrlCustomerType() {
        let url = Utility.scanUrl(itemTagId: "xyz-456", itemTagType: "customer")

        #expect(url.absoluteString.contains("item_tag_id=xyz-456"))
        #expect(url.absoluteString.contains("type=customer"))
    }

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
