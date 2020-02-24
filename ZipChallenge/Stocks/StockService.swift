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
    func initialiseData() -> Single<Void>
    func fetchStocks() -> Observable<[StockModel]>
    func fetchSavedStocks() -> Observable<[StockModel]>
    func update(stock: StockModel) -> Observable<Void>
}

class ZipStockService {
    private let dataRepository: DataRepository
    private let apiRepository: APIRepository
    
    init(dataRepository: DataRepository, apiRepository: APIRepository) {
        self.dataRepository = dataRepository
        self.apiRepository = apiRepository
    }
}

extension ZipStockService: StockService {
    func initialiseData() -> Single<Void> {
        return dataRepository.loadStocksIntoCache()
    }
    
    func fetchStocks() -> Observable<[StockModel]> {
        return fetchStocksFromAPI()
            .asObservable()
            .materialize()
            .flatMap { [weak self] event -> Observable<[StockModel]> in
                guard let self = self else { return Observable.error(ServiceError.deallocatedResources) }
                switch event {
                case .next(let stockModels):
                    _ = self.dataRepository.save(stockModels)
                    return Observable.just(stockModels)
                case .error(let error):
                    if let urlError = error as? URLError,
                        urlError.code == URLError.Code.notConnectedToInternet { print("No internet") }
                    error.log()
                    return self.fetchSavedStocks()
                case .completed: return .empty()
                }
        }
    }
    
    func fetchSavedStocks() -> Observable<[StockModel]> {
        return dataRepository.fetchStocks()
            .map({ stocks -> [StockModel] in
                stocks.map({ StockModel(stock: $0) })
            })
            .asObservable()
    }
    
    func update(stock: StockModel) -> Observable<Void> {
        return dataRepository.save([stock])
            .asObservable()
    }
    
    private func fetchStocksFromAPI() -> Single<[StockModel]> {
        let stocksEndpoint = Endpoint.stockList
        return apiRepository.fetch(type: StockList.self, at: stocksEndpoint)
            .flatMap({ [weak self] in
                guard let self = self else { return Single.error(ServiceError.deallocatedResources) }
                let stocks = $0.stocks
                let symbols = stocks.map({ $0.symbol })
                let profilesEndpoint = Endpoint.stockProfileList(stocks: symbols)
                return self.apiRepository.fetch(type: StockProfileList.self, at: profilesEndpoint)
                    .map({
                        let stockProfiles = $0.profiles
                        let stockModels = stocks.map({ stock -> StockModel in
                            let profile = stockProfiles.first(where: { $0.symbol == stock.symbol })
                            return StockModel(stock: stock, stockProfile: profile)
                        })
                        return stockModels
                    })
            })
    }
}
