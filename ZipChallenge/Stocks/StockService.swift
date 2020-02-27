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
 It fecthes the profiles and updates the stocks. These are saved to cache
 and persisted. Only these stocks are persisted to save on memory and processing.
 It can be assumed that users will only scroll to stocks that interest them.
 */
protocol StockService {
    var cachedStock: [StockModel] { get }
    
    func initialiseData() -> Observable<Void>
    func fetchStocks() -> Observable<[StockModel]>
    func fetchStockProfiles(for stocks: [StockModel]) -> Observable<[StockModel]>
    func update(stock: StockModel)
}

class ZipStockService {
    var cachedStock: [StockModel] { cacheRepository.cachedStocks }
    
    private let dataRepository: DataRepository
    private let cacheRepository: CacheRepository
    private let apiRepository: APIRepository
    
    init(dataRepository: DataRepository, cacheRepository: CacheRepository, apiRepository: APIRepository) {
        self.dataRepository = dataRepository
        self.cacheRepository = cacheRepository
        self.apiRepository = apiRepository
    }
}

extension ZipStockService: StockService {
    func initialiseData() -> Observable<Void> {
        let stockModels = dataRepository.fetchStocks().map({ StockModel(stock: $0) })
        cacheRepository.set(stocks: stockModels)
        return Observable.just(())
    }
    
    func fetchStocks() -> Observable<[StockModel]> {
        let stocksEndpoint = Endpoint.stockList
        return apiRepository.fetch(type: StockList.self, at: stocksEndpoint)
            .map({ [weak self] stockList -> [StockModel] in
                var stocks = stockList.stocks.map({ StockModel(stock: $0) })
                let favoriteStocks = self?.cacheRepository.cachedFavoriteStocks
                favoriteStocks?.forEach({ favoriteStock in
                    if let index = stocks.firstIndex(of: favoriteStock) {
                        stocks[index].update(isFavorite: true)
                    }
                })
                let stocksWithProfiles = self?.cacheRepository.cachedStocks.filter({ $0.hasProfileData == true })
                stocksWithProfiles?.forEach({ stockWithProfile in
                    if let index = stocks.firstIndex(of: stockWithProfile) {
                        stocks[index].update(with: stockWithProfile)
                    }
                })
                // Order and save the stocks to cache.
                stocks.sort(by: { $0.symbol < $1.symbol })
                self?.cacheRepository.set(stocks: stocks)
                return stocks
            })
            .asObservable()
            .materialize()
            .flatMap({ [weak self] event -> Observable<[StockModel]> in
                guard let self = self else { return Observable.error(MemoryError.nilReference) }
                switch event {
                case .next(let stocks): return Observable.just(stocks)
                case .error: return Observable.just(self.cacheRepository.cachedStocks)
                case .completed: return .empty()
                }
            })
        }
    
    func fetchStockProfiles(for stocks: [StockModel]) -> Observable<[StockModel]> {
        let symbols = stocks.map({ $0.symbol })
        let profilesEndpoint = Endpoint.stockProfileList(stockSymbols: symbols)
        let response: Single<[StockProfileList.StockProfile]>
        // The response JSON format changes if only fetching for one stock or many.
        if symbols.count > 1 {
            response = apiRepository.fetch(type: StockProfileList.self, at: profilesEndpoint).map({ $0.profiles })
        } else {
            response = apiRepository.fetch(type: StockProfileList.StockProfile.self, at: profilesEndpoint).map({ [$0] })
        }
        return response.map({ [weak self] profiles -> [StockModel] in
                guard let stocks = self?.cacheRepository.cachedStocks else { return [] }
                let updatedStocks: [StockModel] = profiles.compactMap({ profile in
                    guard var stock = stocks.first(where: { $0.symbol == profile.symbol }) else { return nil }
                    stock.update(with: profile)
                    return stock
                })
                self?.cacheRepository.update(stocks: updatedStocks)

                // Persist the data in case there is no internet connection.
                // A separate background thread is created so that this background
                // thread is not blocked by an intensive task.
                self?.dataRepository.saveOnSeparateThread(updatedStocks)
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
    
    func update(stock: StockModel) {
        dataRepository.saveOnSeparateThread([stock])
        cacheRepository.update(stocks: [stock])
    }
}
