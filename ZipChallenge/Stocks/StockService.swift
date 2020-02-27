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
                // Save the data to Core Data as backup in case there is no connection to internet.
                // As separate background thread is created to save the data so that this background
                // thread is not blocked by an intensive task.
                DispatchQueue.global(qos: .background).async { self?.dataRepository.save(stocks) }
                
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
        return apiRepository.fetch(type: StockProfileList.self, at: profilesEndpoint)
            .map({ [weak self] profilesList -> [StockModel] in
                let profiles = profilesList.profiles
                guard let stocks = self?.cacheRepository.cachedStocks else { return [] }
                let updatedStocks: [StockModel] = profiles.compactMap({ profile in
                    guard var stock = stocks.first(where: { $0.symbol == profile.symbol }) else { return nil }
                    stock.update(with: profile)
                    return stock
                })
                DispatchQueue.global(qos: .background).async { self?.dataRepository.save(stocks) }
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
    
    func update(stock: StockModel) {
        dataRepository.save([stock])
        cacheRepository.update(stocks: [stock])
    }
}
