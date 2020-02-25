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
                stockList.stocks.map({ StockModel(stock: $0) })
            })
            .asObservable()
            .materialize()
            .flatMap { [weak self] event -> Observable<[StockModel]> in
                guard let self = self else { return Observable.error(ServiceError.deallocatedResources) }
                switch event {
                case .next(let stockModels):
                    DispatchQueue.global().async { self.dataRepository.save(stockModels) }
                    self.cacheRepository.set(stocks: stockModels)
                    return Observable.just(self.cacheRepository.cachedStocks)
                case .error(let error):
                    if let urlError = error as? URLError,
                        urlError.code == URLError.Code.notConnectedToInternet {}
                    error.log()
                    return Observable.just(self.cacheRepository.cachedStocks)
                case .completed: return .empty()
                }
        }
    }
    
    func fetchStockProfiles(for stocks: [StockModel]) -> Observable<[StockModel]> {
        return Observable.just([])
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
