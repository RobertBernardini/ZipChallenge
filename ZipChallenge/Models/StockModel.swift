
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
    var price: Double
    var companyLogo: URL?
    var percentageChange: String
    var changes: Double
    var lastDividend: String
    var sector: String
    var industry: String
    var isFavorite: Bool
}

extension StockModel {
    init(stock: StockList.Stock) {
        self.symbol = stock.symbol
        self.name = stock.name ?? ""
        self.price = stock.price
        self.isFavorite = false
        self.companyLogo = nil
        self.percentageChange = ""
        self.changes = 0
        self.lastDividend = ""
        self.sector = ""
        self.industry = ""
    }
    
    mutating func update(with stockProfile: StockProfileList.StockProfile) {
        companyLogo = URL(string: stockProfile.data.image)
        percentageChange = stockProfile.data.changesPercentage
        changes = stockProfile.data.changes
        lastDividend = stockProfile.data.lastDiv
        sector = stockProfile.data.sector
        industry = stockProfile.data.industry
    }
}

extension StockModel {
    init(stock: Stock) {
        self.symbol = stock.symbol ?? ""
        self.name = stock.name ?? ""
        self.price = stock.price
        self.companyLogo = stock.companyLogo
        self.percentageChange = stock.percentageChange ?? ""
        self.changes = stock.changes
        self.lastDividend = stock.lastDividend ?? ""
        self.sector = stock.sector ?? ""
        self.industry = stock.industry ?? ""
        self.isFavorite = stock.isFavorite
    }
}

extension StockModel {
    mutating func update(price: Double) {
        self.price = price
    }
    
    mutating func update(isFavorite: Bool) {
        self.isFavorite = isFavorite
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
    var stockPrice: String { price.toDollarString() }
    var isFavoriteStock: Bool { isFavorite }
}

extension StockModel: StockDetailDisplayable {
    var stockChanges: String { changes.toDollarString() }
    var stockLastDividend: String { lastDividend }
    var stockSector: String { sector }
    var stockIndustry: String { industry }
}
