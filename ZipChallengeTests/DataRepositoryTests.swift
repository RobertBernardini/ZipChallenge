//
//  DataRepositoryTests.swift
//  ZipChallengeTests
//
//  Created by Robert Bernardini on 27/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import XCTest
import RxSwift
@testable import ZipChallenge

class DataRepositoryTests: XCTestCase {
    private var dataRepository: DataRepository!
    
    override func setUp() {
        dataRepository = ZipDataRepository()
    }

    func testItemsInsertedIntoDatabaseAlphabetically() {
        let stock1 = StockModel(
            symbol: "ZIP",
            name: "Test1",
            price: 10.00,
            companyLogo: nil,
            percentageChange: "+10",
            changes: 5,
            lastDividend: "90",
            sector: "iOS",
            industry: "Software",
            isFavorite: true)
        
        let stock2 = StockModel(
            symbol: "ABC",
            name: "Test2",
            price: 20.00,
            companyLogo: nil,
            percentageChange: "-10",
            changes: 8,
            lastDividend: "300",
            sector: "Android",
            industry: "Software",
            isFavorite: false)
        
        dataRepository.save([stock1, stock2])
        let stocks = dataRepository.fetchStocks()
        XCTAssertTrue(stocks.count == 2)
        XCTAssertTrue(stocks.first?.symbol == "ABC")
        XCTAssertTrue(stocks.last?.symbol == "ZIP")
        XCTAssertTrue(stocks.first?.name == "Test2")
        XCTAssertTrue(stocks.last?.name == "Test1")
    }
}
