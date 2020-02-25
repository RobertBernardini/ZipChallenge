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

protocol FavoriteStockViewModelInputs {
    var startUpdates: PublishRelay<Void> { get }
    var stopUpdatesAndSave: PublishRelay<[StockModel]> { get }
    var fetchFavoriteStocks: PublishRelay<Void> { get }
    var fetchPrices: PublishRelay<Void> { get }
    var setAsFavoriteStock: PublishRelay<StockModel> { get }
    var stockSelected: PublishRelay<StockModel> { get }
}

protocol FavoriteStockViewModelOutputs {
    var favoriteStocks: Driver<[StockModel]> { get }
    var updatedStock: Driver<StockModel> { get }
    var showDetail: Driver<StockModel> { get }
}

protocol FavoriteStockViewModel {
    var inputs: FavoriteStockViewModelInputs { get }
    var outputs: FavoriteStockViewModelOutputs { get }
}

class ZipFavoriteStockViewModel {
    var inputs: FavoriteStockViewModelInputs { self }
    var outputs: FavoriteStockViewModelOutputs { self }
    
    // Inputs
    let startUpdates = PublishRelay<Void>()
    let stopUpdatesAndSave = PublishRelay<[StockModel]>()
    let fetchFavoriteStocks = PublishRelay<Void>()
    let fetchPrices = PublishRelay<Void>()
    let setAsFavoriteStock = PublishRelay<StockModel>()
    let stockSelected = PublishRelay<StockModel>()
    
    // Outputs
    let favoriteStocks: Driver<[StockModel]>
    let updatedStock: Driver<StockModel>
    let showDetail: Driver<StockModel>
    
    private let service: FavoriteStockService
    private let bag = DisposeBag()
    
    init(service: FavoriteStockService) {
        self.service = service
        
        let fetchPrices = self.fetchPrices
        var timer: Timer? = nil
            
        self.startUpdates
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: {
                timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
                    fetchPrices.accept(())
                }
            })
            .disposed(by: bag)
        
        self.stopUpdatesAndSave
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: {
                timer?.invalidate()
                timer = nil
                service.save(stocks: $0)
            })
            .disposed(by: bag)
        
        let updatedStocks = self.fetchPrices
            .flatMap({ _ -> Observable<[StockModel]> in
                let stocks = service.cachedFavoriteStock
                return service.fetchPrices(for: stocks)
            })
        
        let cachedStocks = self.fetchFavoriteStocks
            .flatMap({ _ -> Observable<[StockModel]> in
                Observable.just(service.cachedFavoriteStock)
            })

        self.favoriteStocks = Observable
            .merge([cachedStocks, updatedStocks])
            .asDriver(onErrorJustReturn: [])
        
        self.updatedStock = self.setAsFavoriteStock
            .flatMap({ stock -> Observable<StockModel> in
                return service.update(stock: stock)
            })
            .asDriver(onErrorDriveWith: .empty())
            
        self.showDetail = stockSelected.asDriver(onErrorDriveWith: .empty())
    }
}

extension ZipFavoriteStockViewModel: FavoriteStockViewModel {}
extension ZipFavoriteStockViewModel: FavoriteStockViewModelInputs {}
extension ZipFavoriteStockViewModel: FavoriteStockViewModelOutputs {}
