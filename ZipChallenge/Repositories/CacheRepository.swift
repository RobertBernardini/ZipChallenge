
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

class ZipCacheRepository {
    var cachedStocks: [StockModel] = []
    var cachedFavoriteStocks: [StockModel] {
        cachedStocks.filter({ $0.isFavorite == true })
    }    
}

extension ZipCacheRepository: CacheRepository {
    func update(stocks: [StockModel]) {
        stocks.forEach { stock in
            if let index = cachedStocks.firstIndex(where: { $0.symbol == stock.symbol }) {
                cachedStocks[index] = stock
            }
        }
    }
    
    func set(stocks: [StockModel]) {
        let orderedStocks = stocks.sorted(by: { $0.symbol < $1.symbol })
        self.cachedStocks = orderedStocks
    }
}