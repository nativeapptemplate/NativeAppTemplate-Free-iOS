//
//  DateFormatter+Extensions.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/11/13.
//

import Foundation

extension String {
  static let cardDateString: String = "MMM dd yyyy"
  static let cardTimeString: String = "HH:mm"
}

extension ISO8601DateFormatter {
  convenience init(_ formatOptions: Options, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
    self.init()
    self.formatOptions = formatOptions
    self.timeZone = timeZone
  }
}
extension Formatter {
  nonisolated(unsafe) static let iso8601 = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
  static let isoDateUtc = {
    let dateFormatter = DateFormatter.formatter(for: "yyyy-MM-dd")
    dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
    return dateFormatter
  }()
}

extension String {
  var iso8601: Date? {
    Formatter.iso8601.date(from: self)
  }
}

extension DateFormatter {
  static let cardDateFormatter: DateFormatter = {
    DateFormatter.formatter(for: .cardDateString)
  }()
  
  static let cardTimeFormatter: DateFormatter = {
    DateFormatter.formatter(for: .cardTimeString)
  }()
  
  static let timeAgoInWordsDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .medium
    dateFormatter.doesRelativeDateFormatting = true
    return dateFormatter
  }()
  
  static func formatter(for dateString: String) -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateString
    return dateFormatter
  }
}
