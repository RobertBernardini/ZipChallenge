//
//  StockProtocols.swift
//  ZipCodeChallenge
//
//  Created by Robert Bernardini on 21/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import UIKit

protocol StockPersistable {
    var companyLogo: String { get }
    var percentageChange: String { get }
    var changes: Double { get }
    var symbol: String { get }
    var name: String { get }
    var price: Double { get }
    var lastDividend: String { get }
    var sector: String { get }
    var industry: String { get }
    var isFavorite: Bool { get }
    var hasProfileData: Bool { get }
}

protocol StockDisplayable {
    var stockCompanyLogo: String { get }
    var stockPercentageChange: String { get }
    var stockPercentageChangeColor: UIColor { get }
    var stockSymbol: String { get }
    var stockName: String { get }
    var stockPrice: String { get }
    var isFavoriteStock: Bool { get }
}

protocol StockDetailDisplayable: StockDisplayable {
    var stockChanges: String { get }
    var stockLastDividend: String { get }
    var stockSector: String { get }
    var stockIndustry: String { get }
}

protocol StockDetailHistorical {
    var stockDate: Date { get }
    var stockPrice: Double { get }
}
