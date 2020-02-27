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
    var cachedFavoriteStock: [StockModel] { get }
    
    func fetchPrices(for stocks: [StockModel]) -> Observable<[StockModel]>
    func removeFromFavorite(stock: StockModel) -> Observable<StockModel>
    func save(stocks: [StockModel])
}

class ZipFavoriteStockService {
    var cachedFavoriteStock: [StockModel] { cacheRepository.cachedFavoriteStocks }
    
    private let dataRepository: DataRepository
    private let cacheRepository: CacheRepository
    private let apiRepository: APIRepository
    
    init(
        dataRepository: DataRepository,
        cacheRepository: CacheRepository,
        apiRepository: APIRepository
    ) {
        self.dataRepository = dataRepository
        self.cacheRepository = cacheRepository
        self.apiRepository = apiRepository
    }
}

extension ZipFavoriteStockService: FavoriteStockService {
    func fetchPrices(for stocks: [StockModel]) -> Observable<[StockModel]> {
        let symbols = stocks.map({ $0.symbol })
        let pricesEndpoint = Endpoint.stockPriceList(stockSymbols: symbols)
        return apiRepository.fetch(type: StockPriceList.self, at: pricesEndpoint)
            .map({ [weak self] priceList -> [StockModel] in
                let priceModels = priceList.prices
                let updatedStocks: [StockModel] = priceModels.compactMap({ priceModel in
                    guard var stock = stocks.first(where: { $0.symbol == priceModel.symbol }) else { return nil }
                    stock.update(price: priceModel.price)
                    return stock
                })
                self?.cacheRepository.update(stocks: updatedStocks)
                return updatedStocks
            })
            .asObservable()
            .materialize()
            .flatMap({ event -> Observable<[StockModel]> in
                switch event {
                case .next(let updatedStocks): return Observable.just(updatedStocks)
                case .error: return .empty()
                case .completed: return .empty()
                }
            })
    }
    
    func removeFromFavorite(stock: StockModel) -> Observable<StockModel> {
        dataRepository.save([stock])
        cacheRepository.update(stocks: [stock])
        return Observable.just(stock)
    }
    
    func save(stocks: [StockModel]) {
        dataRepository.save(stocks)
    }
}
