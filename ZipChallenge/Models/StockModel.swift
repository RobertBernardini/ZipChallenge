
//
//  StockModel.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 23/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

struct StockModel {
    var symbol: String
    var name: String
    var price: Decimal
    var companyLogo: URL?
    var percentageChange: String
    var changes: Decimal
    var lastDividend: String
    var sector: String
    var industry: String
    var isFavorite: Bool
}

extension StockModel {
    init(stock: StockList.Stock, stockProfile: StockProfileList.StockProfile?) {
        self.symbol = stock.symbol
        self.name = stock.name ?? ""
        self.price = stock.price
        self.companyLogo = URL(string: stockProfile?.data.image ?? "")
        self.percentageChange = stockProfile?.data.changesPercentage ?? ""
        self.changes = stockProfile?.data.changes ?? 0
        self.lastDividend = stockProfile?.data.lastDiv ?? ""
        self.sector = stockProfile?.data.sector ?? ""
        self.industry = stockProfile?.data.industry ?? ""
        self.isFavorite = false
    }
}

extension StockModel {
    init(stock: Stock) {
        self.symbol = stock.symbol ?? ""
        self.name = stock.name ?? ""
        self.price = stock.price as Decimal? ?? 0
        self.companyLogo = stock.companyLogo
        self.percentageChange = stock.percentageChange ?? ""
        self.changes = stock.changes as Decimal? ?? 0
        self.lastDividend = stock.lastDividend ?? ""
        self.sector = stock.sector ?? ""
        self.industry = stock.industry ?? ""
        self.isFavorite = stock.isFavorite
    }
}

extension StockModel: StockPersistable {}

extension StockModel: StockDisplayable {
    var stockCompanyLogo: URL? { companyLogo }
    var stockPercentageChange: String { percentageChange.trimmingCharacters(in: ["(",")"]) }
    var isStockPercentageChangePositive: Bool {
        let symbol = stockPercentageChange.prefix(1)
        return symbol == "+"
    }
    var stockSymbol: String { symbol }
    var stockName: String { name }
    var stockPrice: String { "\(price)" }
    var isFavoriteStock: Bool { isFavorite }
}

extension StockModel: StockDetailDisplayable {
    var stockChanges: String { "\(changes)" }
    var stockLastDividend: String { lastDividend }
    var stockSector: String { sector }
    var stockIndustry: String { industry }
}
