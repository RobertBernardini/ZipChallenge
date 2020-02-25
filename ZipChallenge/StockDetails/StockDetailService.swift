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
    func fetchPrice(for stock: StockModel) -> Observable<StockModel>
    func fetchPriceHistory(for stock: StockModel) -> Observable<[StockDetailHistorical]>
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
    func fetchPrice(for stock: StockModel) -> Observable<StockModel> {
        let pricesEndpoint = Endpoint.stockPriceList(stocks: [stock.symbol])
        return apiRepository.fetch(type: StockPriceList.self, at: pricesEndpoint)
            .map({ [weak self] priceList -> StockModel in
                guard let priceModel = priceList.prices.first else { return stock }
                var updatedStock = stock
                updatedStock.update(price: priceModel.price)
                self?.cacheRepository.update(stocks: [updatedStock])
                return updatedStock
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
    
    func save(stock: StockModel) {
        dataRepository.save([stock])
    }
}
