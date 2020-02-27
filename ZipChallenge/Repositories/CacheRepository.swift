
//
//  CacheRepository.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 25/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

protocol CacheRepository {
    var cachedStocks: [StockModel] { get }
    var cachedFavoriteStocks: [StockModel] { get }
    
    func update(stocks: [StockModel])
    func set(stocks : [StockModel])
}

// Class that implements the Cache Repository protocol.
// This class is used to save the stock data to be used without the need to constantly fetch from Core Data.
// When the application loads, the caches is populated with the persisted data before being replaced with the
// new web data.
// Data is fetched from the cache by each view so that it is not passed around through classes.
// This data should be a mirror image of Core Data.
class ZipCacheRepository {
    var cachedStocks: [StockModel] = []
    var cachedFavoriteStocks: [StockModel] {
        cachedStocks.filter({ $0.isFavorite == true })
    }    
}

extension ZipCacheRepository: CacheRepository {
    func update(stocks: [StockModel]) {
        stocks.forEach { stock in
            if let index = cachedStocks.firstIndex(of: stock) {
                cachedStocks[index] = stock
            }
        }
    }
    
    func set(stocks: [StockModel]) {
        self.cachedStocks = stocks
    }
}
