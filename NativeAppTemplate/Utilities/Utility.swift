//
//  CurrentTimeZone.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/02/22.
//

import Foundation
import CoreNFC

enum Utility {
  static func currentTimeZone() -> String {
    let defaultTimeZone = String.defaultTimeZone
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
    
    if let timeZone = timeZones.first(where: { $0.key.contains(timeZoneKey) && $0.value.contains(timeZoneHourFormatted) }) {
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

  static func isBlank(_ text: String) -> Bool {
    let trimmed = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    return trimmed.isEmpty
  }

  static func validateEmail(_ email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
  }

  private static func currentTimeZoneHour() -> (Int, Int) {
    let secondsFromGmt: Int = TimeZone.current.secondsFromGMT()
    let hoursFromGmt = (secondsFromGmt / 3600)
    let minutesFromGmt = (abs(secondsFromGmt / 60) % 60)
    return (hoursFromGmt, minutesFromGmt)
  }
  
  private static func currentTimeZoneHourFormatted() -> String {
    let (timeZoneHour, timeZoneMinute) = currentTimeZoneHour()
    let timeZoneHourStringZeroPadding = String(format: "%+.2d:%.2d", timeZoneHour, timeZoneMinute)
    return "(GMT\(timeZoneHourStringZeroPadding))"
  }
}
