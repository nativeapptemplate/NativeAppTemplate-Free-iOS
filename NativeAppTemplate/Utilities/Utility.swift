//
//  Utility.swift
//  NativeAppTemplate
//

import Foundation
import os

enum Utility {
    /// The zone (a key of `timeZones`) to preselect for this device: the one
    /// named after the identifier's city, else the first with its standard
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

        if !city.isEmpty, let zone = timeZones.first(where: { $0.key.contains(city) }) {
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
