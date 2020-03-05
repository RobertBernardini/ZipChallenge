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
*/
protocol FavoriteStockServiceType: BaseStockServiceType {
    var cachedFavoriteStock: [StockModel] { get }
    
    func fetchPrices(for stocks: [StockModel]) -> Observable<Result<[StockModel], Error>>
}

class FavoriteStockService: BaseStockService {
    var cachedFavoriteStock: [StockModel] {
        cacheRepository.cachedStocks.filter({ $0.isFavorite == true })
    }
    
    override init(
        dataRepository: DataRepositoryType,
        cacheRepository: CacheRepositoryType,
        apiRepository: APIRepositoryType
    ) {
        super.init(
            dataRepository: dataRepository,
            cacheRepository: cacheRepository,
            apiRepository: apiRepository)
    }
}

extension FavoriteStockService: FavoriteStockServiceType {
    func fetchPrices(for stocks: [StockModel]) -> Observable<Result<[StockModel], Error>> {
        let symbols = stocks.map({ $0.symbol })
        let pricesEndpoint = Endpoint.stockPriceList(stockSymbols: symbols)
        return apiRepository.fetch(type: StockPriceList.self, at: pricesEndpoint)
            .map({ priceList -> [StockModel] in
                let priceModels = priceList.prices
                let updatedStocks: [StockModel] = priceModels.compactMap({ priceModel in
                    guard var stock = stocks.first(where: { $0.symbol == priceModel.symbol }) else {
                        return nil
                    }
                    stock.update(price: priceModel.price)
                    return stock
                })
                self.cacheRepository.update(stocks: updatedStocks)
                self.dataRepository.saveOnSeparateThread(updatedStocks)
                return updatedStocks
            })
            .asObservable()
            .materialize()
            .flatMap({ event -> Observable<Result<[StockModel], Error>> in
                switch event {
                case .next(let updatedStocks): return Observable.just(.success(updatedStocks))
                case .error(let error): return Observable.just(.failure(error))
                case .completed: return .empty()
                }
            })
    }
}
