//
//  DateFormatter+Extension.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 27/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

extension DateFormatter {
  static func dateOnly() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }
}
