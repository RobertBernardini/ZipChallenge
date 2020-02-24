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
        let date: String
        let open: Decimal
        let close: Decimal
        let adjClose: Decimal
        let high: Decimal
        let low: Decimal
        let volume: Int
        let unadjustedVolume: Int
        let change: Decimal
        let changePercent: Decimal
        let vwap: Decimal
        let label: String
        let changeOverTime: Decimal
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
    var stockPrice: Decimal {
        return close
    }
}
