//
//  Utility.swift
//  NativeAppTemplate
//

import Foundation
import os

enum Utility {
    /// The zone (a key of `timeZones`) to preselect for this device: the one
    /// named exactly after the identifier's city, else one at the device's
    /// standard offset whose name contains the city, else the first at that
    /// offset. The table labels zones by standard offset, so summer time must
    /// not move the match.
    static func currentTimeZone(_ timeZone: TimeZone = .current, date: Date = .now) -> String {
        let timeZoneHourFormatted = standardOffsetFormatted(timeZone, date: date)
        let zonesWithOffset = timeZones.filter { $0.value.contains(timeZoneHourFormatted) }

        guard let firstZoneWithOffset = zonesWithOffset.first else {
            return Strings.defaultTimeZone
        }

        let city = (timeZone.identifier.components(separatedBy: "/").last ?? "")
            .replacingOccurrences(of: "_", with: " ")

        guard !city.isEmpty else { return firstZoneWithOffset.key }

        // The whole name, at any offset: the table's offset for a city can differ
        // from the system's when tzdata changes it before Rails does, and the city
        // still names the zone
        if let zone = timeZones.first(where: { $0.key == city }) {
            return zone.key
        }

        // Part of a name only among zones at this offset: "West" (Australia/West,
        // +08:00) is in "International Date Line West" (-12:00)
        if let zone = zonesWithOffset.first(where: { $0.key.contains(city) }) {
            return zone.key
        }

        return firstZoneWithOffset.key
    }

    static var deviceModel: String {
        var utsnameInstance = utsname()
        uname(&utsnameInstance)
        let optionalString: String? = withUnsafePointer(to: &utsnameInstance.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { ptr in String(validatingCString: ptr) }
        }
        return optionalString ?? "N/A"
    }

    /// The standard (non-summer) offset as the table writes it, e.g. "(GMT-05:00)"
    private static func standardOffsetFormatted(_ timeZone: TimeZone, date: Date) -> String {
        let seconds = timeZone.secondsFromGMT(for: date) - Int(timeZone.daylightSavingTimeOffset(for: date))
        let sign = seconds < 0 ? "-" : "+"
        let minutes = abs(seconds) / 60
        return String(format: "(GMT%@%02d:%02d)", sign, minutes / 60, minutes % 60)
    }
}
