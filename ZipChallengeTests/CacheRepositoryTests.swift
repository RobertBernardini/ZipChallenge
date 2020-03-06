//
//  CacheRepositoryTests.swift
//  ZipChallengeTests
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import XCTest
import RxSwift
@testable import ZipChallenge

class CacheRepositoryTests: XCTestCase {
    private var cacheRepository: CacheRepositoryType!
    
    override func setUp() {
        cacheRepository = CacheRepository()
    }
    
    override func tearDown() {
    }

    func testItemsInsertedIntoCache() {
        let stock1 = StockModel(
            symbol: "ZIP",
            name: "Test1",
            price: 10.00,
            companyLogo: "",
            percentageChange: "+10",
            changes: 5,
            lastDividend: "90",
            sector: "iOS",
            industry: "Software",
            isFavorite: true,
            hasProfileData: false)
        
        let stock2 = StockModel(
            symbol: "ABC",
            name: "Test2",
            price: 20.00,
            companyLogo: "",
            percentageChange: "-10",
            changes: 8,
            lastDividend: "300",
            sector: "Android",
            industry: "Software",
            isFavorite: false,
            hasProfileData: false)
        
        cacheRepository.set(stocks: [stock1, stock2])
        let stocks = cacheRepository.cachedStocks
        XCTAssertTrue(stocks.count == 2)
        XCTAssertTrue(stocks.first?.symbol == "ZIP")
        XCTAssertTrue(stocks.last?.symbol == "ABC")
    }
    
    func testItemUpdatedInCache() {
        let stock1 = StockModel(
            symbol: "ZIP",
            name: "Test1",
            price: 10.00,
            companyLogo: "",
            percentageChange: "+10",
            changes: 5,
            lastDividend: "90",
            sector: "iOS",
            industry: "Software",
            isFavorite: true,
            hasProfileData: false)
        
        cacheRepository.set(stocks: [stock1])
        let stocks = cacheRepository.cachedStocks
        XCTAssertTrue(stocks.count == 1)
        XCTAssertTrue(stocks.first?.symbol == "ZIP")
        XCTAssertTrue(stocks.first?.price == 10)
        XCTAssertTrue(stocks.first?.isFavorite == true)

        let stock2 = StockModel(
            symbol: "ZIP",
            name: "Test2",
            price: 20.00,
            companyLogo: "",
            percentageChange: "-10",
            changes: 8,
            lastDividend: "300",
            sector: "Android",
            industry: "Software",
            isFavorite: false,
            hasProfileData: false)
        
        cacheRepository.update(stocks: [stock2])
        let updatedStocks = cacheRepository.cachedStocks
        XCTAssertTrue(updatedStocks.count == 1)
        XCTAssertTrue(updatedStocks.first?.symbol == "ZIP")
        XCTAssertTrue(updatedStocks.first?.price == 20)
        XCTAssertTrue(updatedStocks.first?.isFavorite == false)
    }
}
