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
    var stocks: Observable<Result<[StockModel], Error>> { get }
    var updatedStocks: Observable<Result<[StockModel], Error>> { get }
    var updatedFavoriteStock: Observable<StockModel> { get }
    var showDetail: Observable<StockModel> { get }
}

protocol StockViewModelType {
    var inputs: StockViewModelInputs { get }
    var outputs: StockViewModelOutputs { get }
}

class StockViewModel {
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
    let stocks: Observable<Result<[StockModel], Error>>
    let updatedStocks: Observable<Result<[StockModel], Error>>
    let updatedFavoriteStock: Observable<StockModel>
    let showDetail: Observable<StockModel>
    
    private let service: StockServiceType
    private let bag = DisposeBag()
    
    init(service: StockServiceType) {
        self.service = service
        self.dataInitialized = self.initializeData
            .flatMap({
                service.initialiseData()
            })
        
        let newStocks = self.fetchStocks
            .flatMap({ _ -> Observable<Result<[StockModel], Error>> in
                service.fetchStocks()
            })
        
        let cachedStocks = self.fetchCachedStocks
            .flatMap({ _ -> Observable<Result<[StockModel], Error>> in
                Observable.just(.success(service.cachedStock))
            })

        self.stocks = Observable
            .merge([cachedStocks, newStocks])
        
        let fetchStockProfiles = PublishRelay<[StockModel]>()
        self.fetchProfiles
            .map({ stocks -> [[StockModel]] in
                // Only a maximum of three (3) profiles can be fetched at a time by the Fetch
                // Profile API web service, therefore, the stocks must be split into an array
                // containing arrays of three or less stocks.
                return stocks.toChunks(of: 3)
            })
            .subscribe(onNext: {
                $0.forEach({
                    fetchStockProfiles.accept($0)
                })
            })
            .disposed(by: bag)
        
        self.updatedStocks = fetchStockProfiles
            .flatMap({ stocks -> Observable<Result<[StockModel], Error>> in
                return service.fetchStockProfiles(for: stocks)
            })
        
        self.updatedFavoriteStock = self.setAsFavoriteStock
            .flatMap({ stock -> Observable<StockModel> in
                service.updateAsFavorite(stock: stock)
                return Observable.just(stock)
            })
            
        self.showDetail = self.stockSelected.asObservable()
    }
}

extension StockViewModel: StockViewModelType {}
extension StockViewModel: StockViewModelInputs {}
extension StockViewModel: StockViewModelOutputs {}
