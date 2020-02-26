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
    func fetchPrice(for stock: StockModel) -> Single<StockModel>
    func fetchPriceHistory(for stock: StockModel) -> Single<[StockDetailHistorical]>
    func save(stock: StockModel)
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
    func fetchPrice(for stock: StockModel) -> Single<StockModel> {
        let symbols = [stock.symbol]
        let pricesEndpoint = Endpoint.stockPriceList(stockSymbols: symbols)
        return apiRepository.fetch(type: StockPriceList.self, at: pricesEndpoint)
            .map({ [weak self] priceList -> StockModel in
                guard let priceModel = priceList.prices.first else { return stock }
                var updatedStock = stock
                updatedStock.update(price: priceModel.price)
                self?.cacheRepository.update(stocks: [updatedStock])
                return updatedStock
            })
    }
    
    func fetchPriceHistory(for stock: StockModel) -> Single<[StockDetailHistorical]> {
        let today = Date()
        let threeYearsAgo = Calendar.current.date(byAdding: .year, value: -3, to: today) ?? Date()
        let historicalEndpoint = Endpoint.stockHistory(stockSymbol: stock.symbol, startDate: threeYearsAgo, endDate: today)
        return apiRepository.fetch(type: StockHistory.self, at: historicalEndpoint)
            .map({ history -> [StockDetailHistorical] in
                let historicals = history.historicalMoments
                return historicals
            })
    }
    
    func save(stock: StockModel) {
        dataRepository.save([stock])
    }
}
