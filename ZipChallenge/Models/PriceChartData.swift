//
//  PriceChartData.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 25/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

enum PriceChartDuration: CaseIterable {
    case threeMonths
    case sixMonths
    case oneYear
    case threeYears
    
    static let title = "Price Duration Periods"
    static let message = "Please choose an option to see the fluctuations for that period."
    
    var message: String {
        switch self {
        case .threeMonths: return "Last 3 Months"
        case .sixMonths: return "Last 6 Months"
        case .oneYear: return "Last Year"
        case .threeYears: return "Last 3 Years"
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

protocol PriceChartDisplayable {
    var duration: PriceChartDuration { get }
    var historicalPrices: [StockDetailHistorical] { get }
}

struct PriceChartData: PriceChartDisplayable {
    var duration: PriceChartDuration
    var historicalPrices: [StockDetailHistorical]
}
