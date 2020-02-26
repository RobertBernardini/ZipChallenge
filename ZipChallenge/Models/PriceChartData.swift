//
//  PriceChartData.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 25/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

enum PriceChartPeriod {
    case threeMonths
    case sixMonths
    case oneYear
    case threeYears
}

extension PriceChartPeriod {
    static let title = "Stock Price Period"
    static let message = "Please choose an option to see the stock price for that period."
        
    var text: String {
        switch self {
        case .threeMonths: return "3 Months"
        case .sixMonths: return "6 Months"
        case .oneYear: return "1 Year"
        case .threeYears: return "3 Years"
        }
    }
    
    var startDate: Date {
        let today = Date()
        let calendar = Calendar.current
        switch self {
        case .threeMonths: return calendar.date(byAdding: .month, value: -3, to: today) ?? Date()
        case .sixMonths: return calendar.date(byAdding: .month, value: -6, to: today) ?? Date()
        case .oneYear: return calendar.date(byAdding: .year, value: -1, to: today) ?? Date()
        case .threeYears: return calendar.date(byAdding: .year, value: -3, to: today) ?? Date()
        }
    }
}

extension PriceChartPeriod: CaseIterable {}

protocol PriceChartDisplayable {
    var duration: PriceChartPeriod { get }
    var historicalPrices: [StockDetailHistorical] { get }
}

struct PriceChartData: PriceChartDisplayable {
    var duration: PriceChartPeriod
    var historicalPrices: [StockDetailHistorical]
}
