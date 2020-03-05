//
//  StockService.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 21/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/*
 Service that obtains the data requested by the Stock View Model.
 It initialises data from the persistant data store.
 It fetches stocks that are saved to the cache.
 */
protocol StockServiceType: BaseStockServiceType {
    var cachedStock: [StockModel] { get }
    
    func initialiseData() -> Observable<Void>
    func fetchStocks() -> Observable<Result<[StockModel], Error>>
}

class StockService: BaseStockService {
    var cachedStock: [StockModel] { cacheRepository.cachedStocks }
    
    override init(
        dataRepository: DataRepositoryType,
        cacheRepository: CacheRepositoryType,
        apiRepository: APIRepositoryType
    ) {
        super.init(
            dataRepository: dataRepository,
            cacheRepository: cacheRepository,
            apiRepository: apiRepository)
    }
}

extension StockService: StockServiceType {
    func initialiseData() -> Observable<Void> {
        let stockModels = dataRepository.fetchStocks().map({ StockModel(stock: $0) })
        cacheRepository.set(stocks: stockModels)
        return Observable.just(())
    }
    
    func fetchStocks() -> Observable<Result<[StockModel], Error>> {
        let stocksEndpoint = Endpoint.stockList
        return apiRepository.fetch(type: StockList.self, at: stocksEndpoint)
            .map({ stockList -> [StockModel] in
                var stocks = stockList.stocks.map({ StockModel(stock: $0) })
                let favoriteStocks = self.cacheRepository.cachedStocks.filter({ $0.isFavorite == true })
                favoriteStocks.forEach({ favoriteStock in
                    if let index = stocks.firstIndex(of: favoriteStock) {
                        stocks[index].update(isFavorite: true)
                    }
                })
                let stocksWithProfiles = self.cacheRepository.cachedStocks.filter({ $0.hasProfileData == true })
                stocksWithProfiles.forEach({ stockWithProfile in
                    if let index = stocks.firstIndex(of: stockWithProfile) {
                        stocks[index].update(with: stockWithProfile)
                    }
                })
                // Order and save the stocks to cache.
                stocks.sort(by: { $0.symbol < $1.symbol })
                self.cacheRepository.set(stocks: stocks)
                return stocks
            })
            .asObservable()
            .materialize()
            .flatMap({ event -> Observable<Result<[StockModel], Error>> in
                switch event {
                case .next(let stocks): return Observable.just(.success(stocks))
                case .error(let error): return Observable.just(.failure(error))
                case .completed: return .empty()
                }
            })
        }
}
