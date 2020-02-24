//
//  StockPriceList.swift
//  ZipCodeChallenge
//
//  Created by Robert Bernardini on 21/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

struct StockPriceList {
    struct StockPrice {
        let symbol: String
        let price: Decimal
    }

    let prices: [StockPrice]
}

extension StockPriceList: Decodable {
    enum CodingKeys: String, CodingKey {
        case prices = "companiesPriceList"
    }
}

extension StockPriceList.StockPrice: Decodable {}
