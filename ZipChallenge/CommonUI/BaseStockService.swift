//
//  BaseStockService.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 5/3/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/*
 Service that fecthes the profiles and updates the stocks. These are saved to cache
 and persisted. Only these stocks are persisted to save on memory and processing.
 It can be assumed that users will only scroll to stocks that interest them.
 It updates favorite stocks.
 */
protocol BaseStockServiceType {
    func fetchStockProfiles(for stocks: [StockModel]) -> Observable<Result<[StockModel], Error>>
    func updateAsFavorite(stock: StockModel)
}

class BaseStockService {
    let dataRepository: DataRepositoryType
    let cacheRepository: CacheRepositoryType
    let apiRepository: APIRepositoryType
    
    init(
        dataRepository: DataRepositoryType,
        cacheRepository: CacheRepositoryType,
        apiRepository: APIRepositoryType
    ) {
        self.dataRepository = dataRepository
        self.cacheRepository = cacheRepository
        self.apiRepository = apiRepository
    }
}

extension BaseStockService: BaseStockServiceType {
    func fetchStockProfiles(for stocks: [StockModel]) -> Observable<Result<[StockModel], Error>> {
        let symbols = stocks.map({ $0.symbol })
        let profilesEndpoint = Endpoint.stockProfileList(stockSymbols: symbols)
        let response: Single<[StockProfileList.StockProfile]>
        // The response JSON format changes if only fetching for one stock or many.
        if symbols.count > 1 {
            response = apiRepository.fetch(type: StockProfileList.self, at: profilesEndpoint).map({ $0.profiles })
        } else {
            response = apiRepository.fetch(type: StockProfileList.StockProfile.self, at: profilesEndpoint).map({ [$0] })
        }
        return response.map({ profiles -> [StockModel] in
                let stocks = self.cacheRepository.cachedStocks
                let updatedStocks: [StockModel] = profiles.compactMap({ profile in
                    guard var stock = stocks.first(where: { $0.symbol == profile.symbol }) else { return nil }
                    stock.update(with: profile)
                    return stock
                })
                self.cacheRepository.update(stocks: updatedStocks)

                // Persist the data in case there is no internet connection.
                // A separate background thread is created so that this background
                // thread is not blocked by an intensive task.
                self.dataRepository.saveOnSeparateThread(updatedStocks)
                return updatedStocks
            })
            .asObservable()
            .materialize()
            .flatMap({ event -> Observable<Result<[StockModel], Error>> in
                switch event {
                case .next(let updatedStocks): return Observable.just(.success(updatedStocks))
                case .error(let error): return Observable.just(.failure(error))
                case .completed: return .empty()
                }
            })
    }
    
    func updateAsFavorite(stock: StockModel) {
        dataRepository.saveOnSeparateThread([stock])
        cacheRepository.update(stocks: [stock])
    }
}
