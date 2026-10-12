//
//  DateFormatter+Extensions.swift
//  NativeAppTemplate
//

import Foundation

extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
        self.init()
        self.formatOptions = formatOptions
        self.timeZone = timeZone
    }
}

extension Formatter {
    nonisolated(unsafe) static let iso8601 = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
}

extension String {
    var iso8601: Date? {
        Formatter.iso8601.date(from: self)
    }
}

extension DateFormatter {
    static let cardDateFormatter: DateFormatter = .formatter(for: "yyyy/MM/dd")

    static let cardTimeFormatter: DateFormatter = .formatter(for: "HH:mm")

    static func formatter(for dateString: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateString
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }
}
