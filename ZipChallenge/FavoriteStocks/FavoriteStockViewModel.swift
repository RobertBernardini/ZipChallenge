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
    var fetchProfiles: PublishRelay<[StockModel]> { get }
    var removeFromFavoriteStock: PublishRelay<StockModel> { get }
    var stockSelected: PublishRelay<StockModel> { get }
}

protocol FavoriteStockViewModelOutputs {
    var favoriteStocks: Observable<[StockModel]> { get }
    var updatedStocks: Observable<[StockModel]> { get }
    var removedStock: Observable<StockModel> { get }
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
    let fetchProfiles = PublishRelay<[StockModel]>()
    let removeFromFavoriteStock = PublishRelay<StockModel>()
    let stockSelected = PublishRelay<StockModel>()
    
    // Outputs
    let favoriteStocks: Observable<[StockModel]>
    let updatedStocks: Observable<[StockModel]>
    let removedStock: Observable<StockModel>
    let showDetail: Driver<StockModel>
    
    private let service: FavoriteStockService
    private let bag = DisposeBag()
    
    init(service: FavoriteStockService) {
        self.service = service
        
        let fetchPrices = PublishRelay<Void>()
        var timer: Timer? = nil
            
        self.startUpdates
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: {
                timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
                    fetchPrices.accept(())
                }
            })
            .disposed(by: bag)
        
        self.stopUpdatesAndSave
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: {
                timer?.invalidate()
                timer = nil
                service.save(stocks: $0)
            })
            .disposed(by: bag)
        
        self.favoriteStocks = self.fetchFavoriteStocks
            .flatMap({ _ -> Observable<[StockModel]> in
                Observable.just(service.cachedFavoriteStock)
            })
        
        let updatedProfiles = self.fetchProfiles
            .flatMap({ stocks -> Observable<[StockModel]> in
                print("\(stocks.map({ $0.symbol }).description)")
                return service.fetchStockProfiles(for: stocks)
            })
        
        let updatedPrices = fetchPrices
            .flatMap({ _ -> Observable<[StockModel]> in
                let stocks = service.cachedFavoriteStock
                return service.fetchPrices(for: stocks)
            })
        self.updatedStocks = Observable.merge([updatedProfiles, updatedPrices])
        
        self.removedStock = self.removeFromFavoriteStock
            .flatMap({ stock -> Observable<StockModel> in
                return service.removeFromFavorite(stock: stock)
            })
            
        self.showDetail = stockSelected.asDriver(onErrorDriveWith: .empty())
    }
}

extension ZipFavoriteStockViewModel: FavoriteStockViewModel {}
extension ZipFavoriteStockViewModel: FavoriteStockViewModelInputs {}
extension ZipFavoriteStockViewModel: FavoriteStockViewModelOutputs {}
