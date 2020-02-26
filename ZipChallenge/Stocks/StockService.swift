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
    
    func initialiseData() -> Single<Void>
    func fetchStocks() -> Single<[StockModel]>
    func fetchStockProfiles(for stocks: [StockModel]) -> Single<[StockModel]>
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
    func initialiseData() -> Single<Void> {
        let stockModels = dataRepository.fetchStocks().map({ StockModel(stock: $0) })
        cacheRepository.set(stocks: stockModels)
        return Single.just(())
    }
    
    func fetchStocks() -> Single<[StockModel]> {
        let stocksEndpoint = Endpoint.stockList
        return apiRepository.fetch(type: StockList.self, at: stocksEndpoint)
            .map({ [weak self] stockList -> [StockModel] in
                var stocks = stockList.stocks.map({ StockModel(stock: $0) })
                let favoriteStocks = self?.cacheRepository.cachedFavoriteStocks
                favoriteStocks?.forEach({ favoriteStock in
                    if let index = stocks.firstIndex(where: { $0.symbol == favoriteStock.symbol }) {
                        stocks[index].update(isFavorite: true)
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
            
            
            
//            .asObservable()
//            .materialize()
//            .flatMap { [weak self] event -> Observable<[StockModel]> in
//                guard let self = self else { return Observable.error(ServiceError.deallocatedResources) }
//                switch event {
//                case .next(let stockModels):
//                    
//                    DispatchQueue.global().async {  }
//                    self.cacheRepository.set(stocks: stockModels)
//                    return Observable.just(self.cacheRepository.cachedStocks)
//                case .error(let error):
//                    if let urlError = error as? URLError,
//                        urlError.code == URLError.Code.notConnectedToInternet {}
//                    error.log()
//                    return Observable.just(self.cacheRepository.cachedStocks)
//                case .completed: return .empty()
//                }
//        }
    }
    
    func fetchStockProfiles(for stocks: [StockModel]) -> Single<[StockModel]> {
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
                self?.cacheRepository.update(stocks: updatedStocks)
                return updatedStocks
            })
    }
    
    func update(stock: StockModel) {
        dataRepository.save([stock])
        cacheRepository.update(stocks: [stock])
    }
    
//    private func fetchStocksFromAPI() -> Single<[StockModel]> {
//        let stocksEndpoint = Endpoint.stockList
//        return apiRepository.fetch(type: StockList.self, at: stocksEndpoint)
//            .flatMap({ [weak self] in
//                guard let self = self else { return Single.error(ServiceError.deallocatedResources) }
//                let stocks = $0.stocks
//                var symbols = stocks.map({ $0.symbol })
//                let profilesEndpoint = Endpoint.stockProfileList(stocks: symbols)
//                return self.apiRepository.fetch(type: StockProfileList.self, at: profilesEndpoint)
//                    .map({
//                        let stockProfiles = $0.profiles
//                        let stockModels = stocks.map({ stock -> StockModel in
//                            let profile = stockProfiles.first(where: { $0.symbol == stock.symbol })
//                            return StockModel(stock: stock, stockProfile: profile)
//                        })
//                        return stockModels
//                    })
//            })
//    }
}
