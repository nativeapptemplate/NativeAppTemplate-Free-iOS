//
//  DateExtensionsTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

struct DateExtensionsTest {
    private func date(_ iso: String) throws -> Date {
        try #require(iso.iso8601)
    }

    @Test
    func cardDateStringFormatsAsYearMonthDay() throws {
        let date = try date("2026-04-29T12:34:56.000Z")
        let formatted = date.cardDateString
        // Output is locale-fixed (en_US_POSIX) but uses the device's current
        // time zone, so we just assert the format shape.
        #expect(formatted.count == 10)
        #expect(formatted.contains("/"))
        let parts = formatted.split(separator: "/")
        #expect(parts.count == 3)
        #expect(parts[0].count == 4) // year
        #expect(parts[1].count == 2) // month
        #expect(parts[2].count == 2) // day
    }

    @Test
    func cardTimeStringFormatsAsHourMinute() throws {
        let date = try date("2026-04-29T12:34:56.000Z")
        let formatted = date.cardTimeString
        #expect(formatted.count == 5)
        #expect(formatted[formatted.index(formatted.startIndex, offsetBy: 2)] == ":")
    }

    @Test
    func cardDateTimeStringConcatenatesDateAndTime() throws {
        let date = try date("2026-04-29T12:34:56.000Z")
        let combined = date.cardDateTimeString
        #expect(combined == "\(date.cardDateString) \(date.cardTimeString)")
    }
}
