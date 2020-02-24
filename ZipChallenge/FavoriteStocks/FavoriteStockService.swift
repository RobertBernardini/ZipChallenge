//
//  FavoriteStockService.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 21/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol FavoriteStockService {
    func fetchPrices(for stocks: [StockModel]) -> Observable<[StockModel]>
    func save(stocks: [StockModel]) -> Observable<Void>
    func update(stock: StockModel) -> Observable<Void>
}

class ZipFavoriteStockService {
    private let dataRepository: DataRepository
    private let apiRepository: APIRepository
    
    init(dataRepository: DataRepository, apiRepository: APIRepository) {
        self.dataRepository = dataRepository
        self.apiRepository = apiRepository
    }
}

extension ZipFavoriteStockService: FavoriteStockService {
    func fetchPrices(for stocks: [StockModel]) -> Observable<[StockModel]> {
        let symbols = stocks.map({ $0.symbol })
        let pricesEndpoint = Endpoint.stockPriceList(stocks: symbols)
        return apiRepository.fetch(type: StockPriceList.self, at: pricesEndpoint)
            .map({ priceList -> [StockModel] in
                let priceModels = priceList.prices
                let updatedStocks: [StockModel] = priceModels.compactMap({ priceModel in
                    guard var stock = stocks.first(where: { $0.symbol == priceModel.symbol }) else { return nil }
                    stock.price = priceModel.price
                    return stock
                })
                return updatedStocks
            })
            .asObservable()
    }
    
    func save(stocks: [StockModel]) -> Observable<Void> {
        return dataRepository.save(stocks)
            .asObservable()
    }
    
    func update(stock: StockModel) -> Observable<Void> {
        return dataRepository.save([stock])
            .asObservable()
    }
}
