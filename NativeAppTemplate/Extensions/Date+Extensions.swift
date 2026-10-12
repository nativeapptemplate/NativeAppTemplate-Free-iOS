//
//  Date+Extensions.swift
//  NativeAppTemplate
//

import Foundation

extension Date {
    var cardDateString: String {
        let formatter = DateFormatter.cardDateFormatter
        return formatter.string(from: self)
    }

    var cardTimeString: String {
        let formatter = DateFormatter.cardTimeFormatter
        return formatter.string(from: self)
    }

    var cardDateTimeString: String {
        "\(cardDateString) \(cardTimeString)"
    }
}
