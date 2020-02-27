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
protocol StockDetailService {
    func fetchPrice(for stock: StockModel) -> Observable<StockModel>
    func fetchPriceHistory(for stock: StockModel) -> Observable<[StockDetailHistorical]>
}

class ZipStockDetailService {
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

extension ZipStockDetailService: StockDetailService {
    func fetchPrice(for stock: StockModel) -> Observable<StockModel> {
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
            .flatMap({ event -> Observable<StockModel> in
                switch event {
                case .next(let updatedStocks): return Observable.just(updatedStocks)
                case .error: return .empty()
                case .completed: return .empty()
                }
            })
    }
    
    func fetchPriceHistory(for stock: StockModel) -> Observable<[StockDetailHistorical]> {
        let today = Date()
        let threeYearsAgo = Calendar.current.date(byAdding: .year, value: -3, to: today) ?? Date()
        let historicalEndpoint = Endpoint.stockHistory(stockSymbol: stock.symbol, startDate: threeYearsAgo, endDate: today)
        return apiRepository.fetch(type: StockHistory.self, at: historicalEndpoint)
            .map({ history -> [StockDetailHistorical] in
                let historicals = history.historicalMoments
                return historicals
            })
            .asObservable()
            .materialize()
            .flatMap({ event -> Observable<[StockDetailHistorical]> in
                switch event {
                case .next(let updatedStocks): return Observable.just(updatedStocks)
                case .error: return .empty()
                case .completed: return .empty()
                }
            })
    }
}
