
//
//  CacheRepository.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 25/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

/*
 Repository that is used to save the stock data to be used without the need to
 constantly fetch from the persistent store.
 When the application loads, the caches is populated with the persisted data before
 being replaced with the new web data.
 
 */
protocol CacheRepository {
    var cachedStocks: [StockModel] { get }
    var cachedFavoriteStocks: [StockModel] { get }
    
    func update(stocks: [StockModel])
    func set(stocks : [StockModel])
}

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
