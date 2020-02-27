//
//  StockViewModel.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/*
 View model that manages the requests of the Stock View Controller and
 returns the required data to be displayed. It uses Rx to bind signals
 and observers.
 */
protocol StockViewModelInputs {
    var initializeData: PublishRelay<Void> { get }
    var fetchCachedStocks: PublishRelay<Void> { get }
    var fetchStocks: PublishRelay<Void> { get }
    var fetchProfiles: PublishRelay<[StockModel]> { get }
    var setAsFavoriteStock: PublishRelay<StockModel> { get }
    var stockSelected: PublishRelay<StockModel> { get }
}

protocol StockViewModelOutputs {
    var dataInitialized: Observable<Void> { get }
    var stocks: Observable<[StockModel]> { get }
    var updatedStocks: Observable<[StockModel]> { get }
    var favoriteStock: Observable<StockModel> { get }
    var showDetail: Driver<StockModel> { get }
}

protocol StockViewModel {
    var inputs: StockViewModelInputs { get }
    var outputs: StockViewModelOutputs { get }
}

class ZipStockViewModel {
    var inputs: StockViewModelInputs { self }
    var outputs: StockViewModelOutputs { self }
    
    // Inputs
    let initializeData = PublishRelay<Void>()
    let fetchCachedStocks = PublishRelay<Void>()
    let fetchStocks = PublishRelay<Void>()
    let fetchProfiles = PublishRelay<[StockModel]>()
    let setAsFavoriteStock = PublishRelay<StockModel>()
    let stockSelected = PublishRelay<StockModel>()
    
    // Outputs
    let dataInitialized: Observable<Void>
    let stocks: Observable<[StockModel]>
    let updatedStocks: Observable<[StockModel]>
    let favoriteStock: Observable<StockModel>
    let showDetail: Driver<StockModel>
    
    private let service: StockService
    private let bag = DisposeBag()
    
    init(service: StockService) {
        self.service = service
        self.dataInitialized = self.initializeData
            .flatMap({
                service.initialiseData()
            })
        
        let newStocks = self.fetchStocks
            .flatMap({ _ -> Observable<[StockModel]> in
                service.fetchStocks()
            })
        
        let cachedStocks = self.fetchCachedStocks
            .flatMap({ _ -> Observable<[StockModel]> in
                Observable.just(service.cachedStock)
            })

        self.stocks = Observable
            .merge([cachedStocks, newStocks])
        
        self.updatedStocks = self.fetchProfiles
            .flatMap({ stocks -> Observable<[StockModel]> in
                return service.fetchStockProfiles(for: stocks)
            })
        
        self.favoriteStock = self.setAsFavoriteStock
            .flatMap({ stock -> Observable<StockModel> in
                service.update(stock: stock)
                return Observable.just(stock)
            })
            
        self.showDetail = stockSelected.asDriver(onErrorDriveWith: .empty())
    }
}

extension ZipStockViewModel: StockViewModel {}
extension ZipStockViewModel: StockViewModelInputs {}
extension ZipStockViewModel: StockViewModelOutputs {}
