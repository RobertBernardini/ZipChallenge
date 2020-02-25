//
//  Double+Currency.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 25/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

extension Double {
    func toDollarString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.currencyDecimalSeparator = "."
        return formatter.string(from: self as NSNumber) ?? ""
    }
}
