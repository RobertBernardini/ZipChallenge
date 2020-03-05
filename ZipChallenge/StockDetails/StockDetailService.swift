//
//  StockDetailService.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 21/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/*
 Service that obtains the data requested by the Stock Detail View Model.
 It fetches the price and updates the stock.
 It fecthes the price history returns it. This data is not persisted.
*/
protocol StockDetailServiceType {
    func fetchPrice(for stock: StockModel) -> Observable<Result<StockModel, Error>>
    func fetchPriceHistory(for stock: StockModel) -> Observable<Result<[StockDetailHistorical], Error>>
}

class StockDetailService {
    private let dataRepository: DataRepositoryType
    private let cacheRepository: CacheRepositoryType
    private let apiRepository: APIRepositoryType
    
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

extension StockDetailService: StockDetailServiceType {
    func fetchPrice(for stock: StockModel) -> Observable<Result<StockModel, Error>> {
        let symbols = [stock.symbol]
        let pricesEndpoint = Endpoint.stockPriceList(stockSymbols: symbols)
        return apiRepository.fetch(type: StockPriceList.StockPrice.self, at: pricesEndpoint)
            .map({ [weak self] priceModel -> StockModel in
                var updatedStock = stock
                updatedStock.update(price: priceModel.price)
                self?.dataRepository.saveOnSeparateThread([updatedStock])
                self?.cacheRepository.update(stocks: [updatedStock])
                return updatedStock
            })
            .asObservable()
            .materialize()
            .flatMap({ event -> Observable<Result<StockModel, Error>> in
                switch event {
                case .next(let updatedStock): return Observable.just(.success(updatedStock))
                case .error(let error):
                    error.log()
                    return Observable.just(.failure(error))
                case .completed: return .empty()
                }
            })
    }
    
    func fetchPriceHistory(for stock: StockModel) -> Observable<Result<[StockDetailHistorical], Error>> {
        let today = Date()
        let threeYearsAgo = Calendar.current.date(byAdding: .year, value: -3, to: today) ?? Date()
        let historicalEndpoint = Endpoint.stockHistory(
            stockSymbol: stock.symbol,
            startDate: threeYearsAgo,
            endDate: today)
        return apiRepository.fetch(type: StockHistory.self, at: historicalEndpoint)
            .map({ $0.historicalMoments })
            .asObservable()
            .materialize()
            .flatMap({ event -> Observable<Result<[StockDetailHistorical], Error>> in
                switch event {
                case .next(let historicals): return Observable.just(.success(historicals))
                case .error(let error): return Observable.just(.failure(error))
                case .completed: return .empty()
                }
            })
    }
}
