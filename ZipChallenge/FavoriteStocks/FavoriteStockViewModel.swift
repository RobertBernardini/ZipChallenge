//
//  FavoriteStockViewModel.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol FavoriteStockViewModel {
    typealias favoriteTuple = (symbol: String, isFavorite: Bool)

    // Inputs
//    var startTimer: PublishRelay<Void> { get }
//    var stopTimer: PublishRelay<Void> { get }
//    var saveStocks: PublishRelay<Void> { get }
//    var setAsFavoriteStock: PublishRelay<favoriteTuple> { get }
//    var selectedStock: PublishRelay<StockModel> { get }
//    
//    // Outputs
//    var stocks: BehaviorRelay<[StockModel]> { get }
//    var priceUpdatedStocks: Observable<[StockModel]> { get }
//    var updatedStock: Observable<StockModel> { get }
//    var showDetail: Observable<StockModel> { get }
}

class ZipFavoriteStockViewModel {
    // Inputs
    var startTimer = PublishRelay<Void>()
    var stopTimer = PublishRelay<Void>()
    var saveStocks = PublishRelay<Void>()
    var setAsFavoriteStock = PublishRelay<favoriteTuple>()
    var selectedStock = PublishRelay<StockModel>()
    
    // Outputs
    var stocks: BehaviorRelay<[StockModel]>
    var priceUpdatedStocks: Observable<[StockModel]>
    var updatedStock: Observable<StockModel>
    var showDetail: Observable<StockModel>
    
    private let service: FavoriteStockService
    private let disposeBag = DisposeBag()
    
    init(service: FavoriteStockService) {
        self.service = service
        
        

//        self.updatedStock = self.setAsFavoriteStock
//            .map({ [unowned self] tuple -> StockModel? in
//                let stocks = self.stocks.value
//                var favoriteStock = stocks.first(where: { $0.symbol == tuple.symbol })
//                favoriteStock?.isFavorite = true
//                return favoriteStock
//            })
//            .flatMap({ [weak self] favoriteStock -> Observable<StockModel> in
//                guard let favoriteStock = favoriteStock else { return Observable.error(ViewModelError.nilStock) }
//                return service.update(stock: favoriteStock)
//                    .map({
//                        if var stocks = self?.stocks.value,
//                            let index = stocks.firstIndex(where: { $0.symbol == favoriteStock.symbol }) {
//                            stocks[index].isFavorite = true
//                            self?.stocks.accept(stocks)
//                        }
//                        return favoriteStock
//                    })
//            })
    }
}

extension ZipFavoriteStockViewModel: FavoriteStockViewModel {}
