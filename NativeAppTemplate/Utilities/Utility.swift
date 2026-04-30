//
//  Utility.swift
//  NativeAppTemplate
//

import Foundation
import os

enum Utility {
    static func currentTimeZone() -> String {
        let defaultTimeZone = Strings.defaultTimeZone
        let timeZoneHourFormatted = currentTimeZoneHourFormatted()

        let timeZoneArray = TimeZone.current.identifier.components(separatedBy: "/")

        if timeZoneArray.isEmpty || timeZoneArray.count != 2 {
            if let timeZone = timeZones.first(where: { $0.value.contains(timeZoneHourFormatted) }) {
                return timeZone.key
            }
        }

        if timeZoneArray.isEmpty {
            return defaultTimeZone
        }

        let timeZoneKey: String = timeZoneArray[1]

        if let timeZone = timeZones
            .first(where: { $0.key.contains(timeZoneKey) && $0.value.contains(timeZoneHourFormatted) }) {
            return timeZone.key
        }

        if let timeZone = timeZones.first(where: { $0.value.contains(timeZoneHourFormatted) }) {
            return timeZone.key
        }

        return defaultTimeZone
    }

    static var deviceModel: String {
        var utsnameInstance = utsname()
        uname(&utsnameInstance)
        let optionalString: String? = withUnsafePointer(to: &utsnameInstance.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { ptr in String(validatingCString: ptr) }
        }
        return optionalString ?? "N/A"
    }

    private static func currentTimeZoneHour() -> (Int, Int) {
        let secondsFromGmt: Int = TimeZone.current.secondsFromGMT()
        let hoursFromGmt = (secondsFromGmt / 3_600)
        let minutesFromGmt = (abs(secondsFromGmt / 60) % 60)
        return (hoursFromGmt, minutesFromGmt)
    }

    private static func currentTimeZoneHourFormatted() -> String {
        let (timeZoneHour, timeZoneMinute) = currentTimeZoneHour()
        let timeZoneHourStringZeroPadding = String(format: "%+.2d:%.2d", timeZoneHour, timeZoneMinute)
        return "(GMT\(timeZoneHourStringZeroPadding))"
    }
}
