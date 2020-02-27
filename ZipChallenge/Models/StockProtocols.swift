//
//  StockProtocols.swift
//  ZipCodeChallenge
//
//  Created by Robert Bernardini on 21/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import UIKit

/*
 Protocol passed to the Data Repository to persist the data.
 */
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

/*
 Protocol used to pass the stock data to the list views so that it
 can be displayed to the user.
 */
protocol StockDisplayable {
    var stockCompanyLogo: String { get }
    var stockPercentageChange: String { get }
    var stockPercentageChangeColor: UIColor { get }
    var stockSymbol: String { get }
    var stockName: String { get }
    var stockPrice: String { get }
    var isFavoriteStock: Bool { get }
}

/*
 Protocol used to pass the stock data to the detail views so that
 it can be displayed to the user. It conforms to the StockDisplayable
 protocol.
 */
protocol StockDetailDisplayable: StockDisplayable {
    var stockChanges: String { get }
    var stockLastDividend: String { get }
    var stockSector: String { get }
    var stockIndustry: String { get }
}

/*
 Protocol used to parse the historical price data so that it can be
 charted on the price chart.
 */
protocol StockDetailHistorical {
    var stockDate: Date { get }
    var stockPrice: Double { get }
}
