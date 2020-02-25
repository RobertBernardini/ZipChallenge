//
//  StockHistory.swift
//  ZipCodeChallenge
//
//  Created by Robert Bernardini on 21/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

struct StockHistory {
    struct StockHistoricalMoment {
        let date: Date
        let open: Double
        let close: Double
        let adjClose: Double
        let high: Double
        let low: Double
        let volume: Int
        let unadjustedVolume: Int
        let change: Double
        let changePercent: Double
        let vwap: Double
        let label: String
        let changeOverTime: Double
    }
    
    let symbol: String
    let historicalMoments: [StockHistoricalMoment]
}

extension StockHistory: Decodable {
    enum CodingKeys: String, CodingKey {
        case symbol
        case historicalMoments = "historical"
    }
}

extension StockHistory.StockHistoricalMoment: Decodable {}

extension StockHistory.StockHistoricalMoment: StockDetailHistorical {
    var stockDate: Date { date }
    var stockPrice: Double { close }
}
