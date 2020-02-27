
//
//  StockModel.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 23/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import UIKit

/*
 Stock Model is the main object passed throughout the app that
 contains the stock data.
 It conforms to the various protocols so that it can be used to
 persist and display data.
 It also conforms to the Equatable protocol in order to be compared
 more effectively.
 */
struct StockModel {
    var symbol: String
    var name: String
    var price: Double
    var companyLogo: String
    var percentageChange: String
    var changes: Double
    var lastDividend: String
    var sector: String
    var industry: String
    var isFavorite: Bool
    var hasProfileData: Bool
}

extension StockModel {
    init(stock: StockList.Stock) {
        self.symbol = stock.symbol
        self.name = stock.name ?? ""
        self.price = stock.price
        self.isFavorite = false
        self.companyLogo = ""
        self.percentageChange = ""
        self.changes = 0
        self.lastDividend = ""
        self.sector = ""
        self.industry = ""
        self.hasProfileData = false
    }
}

extension StockModel {
    init(stock: Stock) {
        self.symbol = stock.symbol ?? ""
        self.name = stock.name ?? ""
        self.price = stock.price
        self.companyLogo = stock.companyLogo ?? ""
        self.percentageChange = stock.percentageChange ?? ""
        self.changes = stock.changes
        self.lastDividend = stock.lastDividend ?? ""
        self.sector = stock.sector ?? ""
        self.industry = stock.industry ?? ""
        self.isFavorite = stock.isFavorite
        self.hasProfileData = stock.hasProfileData
    }
}

extension StockModel {
    mutating func update(with stockProfile: StockProfileList.StockProfile) {
        companyLogo = stockProfile.data.image ?? ""
        percentageChange = stockProfile.data.changesPercentage ?? ""
        changes = stockProfile.data.changes ?? 0
        lastDividend = stockProfile.data.lastDiv ?? ""
        sector = stockProfile.data.sector ?? ""
        industry = stockProfile.data.industry ?? ""
        hasProfileData = true
    }
    
    mutating func update(with stockModel: StockModel) {
        symbol = stockModel.symbol
        name = stockModel.name
        price = stockModel.price
        companyLogo = stockModel.companyLogo
        percentageChange = stockModel.percentageChange
        changes = stockModel.changes
        lastDividend = stockModel.lastDividend
        sector = stockModel.sector
        industry = stockModel.industry
        isFavorite = stockModel.isFavorite
        hasProfileData = stockModel.hasProfileData
    }
    
    mutating func update(price: Double) {
        self.price = price
    }
    
    mutating func update(isFavorite: Bool) {
        self.isFavorite = isFavorite
    }
}

extension StockModel: StockPersistable {}

extension StockModel: StockDisplayable {
    var stockCompanyLogo: String { companyLogo }
    var stockPercentageChange: String { percentageChange.trimmingCharacters(in: ["(",")"]) }
    var stockPercentageChangeColor: UIColor {
        let symbol = stockPercentageChange.prefix(1)
        switch symbol {
        case "+": return .systemGreen
        case "-": return .red
        default: return .lightGray
        }
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

extension StockModel: Equatable {
    // Should only be equatable if two stocks contain the same "symbol"
    static func ==(lhs: StockModel, rhs: StockModel) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}
