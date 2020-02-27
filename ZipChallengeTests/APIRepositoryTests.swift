//
//  APIRepositoryTests.swift
//  ZipChallengeTests
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import XCTest
import RxSwift
@testable import ZipChallenge

class APIRepositoryTests: XCTestCase {
    var apiRepository: APIRepository!
    var bag: DisposeBag!
    
    override func setUp() {
        apiRepository = ZipAPIRepository()
        bag = DisposeBag()
    }

    func testStocksRetrieved() {
        let endpoint = Endpoint.stockList
        apiRepository.fetch(type: StockList.self, at: endpoint)
            .map({
                let stocks = $0.stocks
                XCTAssertTrue(stocks.count > 0)
            })
        .subscribe()
        .disposed(by: bag)
    }
    
    func testStockPricesRetrieved() {
        let symbols = ["AAPL", "AMZN"]
        let endpoint = Endpoint.stockPriceList(stockSymbols: symbols)
        apiRepository.fetch(type: StockPriceList.self, at: endpoint)
            .map({
                let prices = $0.prices
                XCTAssertTrue(prices.count > 0)
            })
        .subscribe()
        .disposed(by: bag)
    }
    
    func testStockProfilesRetrieved() {
        let symbols = ["AAPL", "AMZN"]
        let endpoint = Endpoint.stockProfileList(stockSymbols: symbols)
        apiRepository.fetch(type: StockProfileList.self, at: endpoint)
            .map({
                let profiles = $0.profiles
                XCTAssertTrue(profiles.count > 0)
            })
        .subscribe()
        .disposed(by: bag)
    }
    
    func testStockHistoryRetrieved() {
        let symbol = "AAPL"
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: endDate) ?? Date()
        let endpoint = Endpoint.stockHistory(stockSymbol: symbol, startDate: startDate, endDate: endDate)
        apiRepository.fetch(type: StockHistory.self, at: endpoint)
            .map({
                let stockHistoricals = $0.historicalMoments
                XCTAssertTrue(stockHistoricals.count > 0)
            })
        .subscribe()
        .disposed(by: bag)
    }
}
