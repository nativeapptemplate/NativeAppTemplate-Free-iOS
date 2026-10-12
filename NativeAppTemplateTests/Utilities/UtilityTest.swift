//
//  UtilityTest.swift
//  NativeAppTemplate
//

import Foundation
@testable import NativeAppTemplate
import Testing

struct UtilityTest {
    // MARK: - currentTimeZone

    /// 2026-07-01 12:00 UTC: summer time in both London (BST, +01:00) and
    /// New York (EDT, -04:00)
    private static let summer = Date(timeIntervalSince1970: 1_782_907_200)
    /// 2026-01-15 12:00 UTC: standard time everywhere in the cases below
    private static let winter = Date(timeIntervalSince1970: 1_768_478_400)

    /// The expected keys come from TimeZoneData.swift, the Rails zone names the
    /// API accepts, whose labels give each zone's standard offset. The zone is
    /// picked by the city from the identifier, with "_" read as " ", else the
    /// first zone with the device's standard offset.
    @Test(arguments: [
        // London is GMT+00:00 in the table; in July the device is at +01:00
        ("Europe/London", summer, "London"),
        ("Europe/London", winter, "London"),
        // The identifier's city is "Buenos_Aires"; the table's is "Buenos Aires"
        ("America/Argentina/Buenos_Aires", winter, "Buenos Aires"),
        ("Asia/Tokyo", summer, "Tokyo"),
        ("Asia/Kolkata", winter, "Kolkata")
    ])
    func currentTimeZoneMatchesCity(identifier: String, date: Date, expected: String) throws {
        let timeZone = try #require(TimeZone(identifier: identifier))
        #expect(Utility.currentTimeZone(timeZone, date: date) == expected)
    }

    /// New York is not in the table, so the zone falls back to the offset.
    /// That must be its standard offset, -05:00 (America/New_York's base UTC
    /// offset), not the summer offset -04:00, which is Atlantic Time.
    @Test(arguments: [summer, winter])
    func currentTimeZoneFallsBackToStandardOffset(date: Date) throws {
        let timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let key = Utility.currentTimeZone(timeZone, date: date)
        let label = try #require(timeZones.first { $0.key == key }?.value)
        #expect(label.hasPrefix("(GMT-05:00)"))
    }
}
