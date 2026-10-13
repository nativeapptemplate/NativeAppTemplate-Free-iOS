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

    /// A city that is only part of a zone's name at another offset must not pick
    /// that zone. The expected key is the first at the device's standard offset in
    /// TimeZoneData.swift, as none at that offset contains the city:
    /// - Australia/West is +08:00 ("West" is in International Date Line West, -12:00);
    ///   the first +08:00 zone is Beijing
    /// - Pacific/Easter (Easter Island) is -06:00 ("Easter" is in Eastern Time, -05:00);
    ///   the first -06:00 zone is Central America
    /// - America/Indiana/Petersburg is -05:00 ("Petersburg" is in St. Petersburg, +03:00);
    ///   the first -05:00 zone is Bogota
    @Test(arguments: [
        ("Australia/West", "Beijing"),
        ("Pacific/Easter", "Central America"),
        ("America/Indiana/Petersburg", "Bogota")
    ])
    func currentTimeZoneIgnoresACityInAZoneAtAnotherOffset(identifier: String, expected: String) throws {
        let timeZone = try #require(TimeZone(identifier: identifier))
        #expect(Utility.currentTimeZone(timeZone, date: Self.winter) == expected)
    }

    /// Part of a name still picks the zone when it is at the device's offset:
    /// Atlantic/Cape_Verde (-01:00) is "Cape Verde Is." (-01:00) in the table
    @Test
    func currentTimeZoneMatchesPartOfANameAtTheSameOffset() throws {
        let timeZone = try #require(TimeZone(identifier: "Atlantic/Cape_Verde"))
        #expect(Utility.currentTimeZone(timeZone, date: Self.winter) == "Cape Verde Is.")
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
