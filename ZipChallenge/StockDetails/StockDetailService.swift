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

protocol StockDetailService {
    func fetchPrices(for stocks: [StockModel]) -> Observable<[StockModel]>
    func fetchPriceHistory(for stock: StockModel) -> Observable<[StockDetailHistorical]>
    func save(stocks: [StockModel]) -> Observable<Void>
}

class ZipStockDetailService {
    private let dataRepository: DataRepository
    private let apiRepository: APIRepository
    
    init(dataRepository: DataRepository, apiRepository: APIRepository) {
        self.dataRepository = dataRepository
        self.apiRepository = apiRepository
    }
}

extension ZipStockDetailService: StockDetailService {
    func fetchPrices(for stocks: [StockModel]) -> Observable<[StockModel]> {
        let symbols = stocks.map({ $0.symbol })
        let pricesEndpoint = Endpoint.stockPriceList(stocks: symbols)
        return apiRepository.fetch(type: StockPriceList.self, at: pricesEndpoint)
            .map({ priceList -> [StockModel] in
                let priceModels = priceList.prices
                let updatedStocks: [StockModel] = priceModels.compactMap({ priceModel in
                    guard var stock = stocks.first(where: { $0.symbol == priceModel.symbol }) else { return nil }
                    stock.price = priceModel.price
                    return stock
                })
                return updatedStocks
            })
            .asObservable()
    }
    
    func fetchPriceHistory(for stock: StockModel) -> Observable<[StockDetailHistorical]> {
        let today = Date()
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: today) ?? Date()
        let historicalEndpoint = Endpoint.stockHistory(stock: stock.symbol, startDate: oneYearAgo, endDate: today)
        return apiRepository.fetch(type: StockHistory.self, at: historicalEndpoint)
            .map({ history -> [StockDetailHistorical] in
                let historicals = history.historicalMoments
                return historicals
            })
            .asObservable()
    }
    
    func save(stocks: [StockModel]) -> Observable<Void> {
        return dataRepository.save(stocks)
            .asObservable()
    }
}
