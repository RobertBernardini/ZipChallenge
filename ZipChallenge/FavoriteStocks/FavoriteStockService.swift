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

/*
 Service that obtains the data requested by the Favorite Stock View Model.
 It has a variable for access to the favorite cached stock.
 It fetches the prices and updates the favorite stocks.
 It fecthes the profiles and updates the favorite stocks.
 It removes the stocks from favorites.
*/
protocol FavoriteStockService {
    var cachedFavoriteStock: [StockModel] { get }
    
    func fetchPrices(for stocks: [StockModel]) -> Observable<[StockModel]>
    func fetchStockProfiles(for stocks: [StockModel]) -> Observable<[StockModel]>
    func removeFromFavorite(stock: StockModel) -> Observable<StockModel>
}

class ZipFavoriteStockService {
    var cachedFavoriteStock: [StockModel] { cacheRepository.cachedFavoriteStocks }
    
    private let dataRepository: DataRepository
    private let cacheRepository: CacheRepository
    private let apiRepository: APIRepository
    
    init(dataRepository: DataRepository, cacheRepository: CacheRepository, apiRepository: APIRepository) {
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
    
    func removeFromFavorite(stock: StockModel) -> Observable<StockModel> {
        dataRepository.saveOnSeparateThread([stock])
        cacheRepository.update(stocks: [stock])
        return Observable.just(stock)
    }
}
