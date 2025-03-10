//
//  Date+Extensions.swift
//  NativeAppTemplate
//
//  Created by Daisuke Adachi on 2023/11/13.
//

import Foundation

extension Date {
  func dateByAddingNumberOfSeconds(_ seconds: Int) -> Date {
    let timeInterval = TimeInterval(seconds)
    return addingTimeInterval(timeInterval)
  }
  
  var cardDateString: String {
    let formatter = DateFormatter.cardDateFormatter
    return formatter.string(from: self)
  }

  var cardTimeString: String {
    let formatter = DateFormatter.cardTimeFormatter
    return formatter.string(from: self)
  }
  
  var cardTimeAgoInWordsDateString: String {
    let formatter = DateFormatter.timeAgoInWordsDateFormatter
    return formatter.string(from: self)
  }
}
