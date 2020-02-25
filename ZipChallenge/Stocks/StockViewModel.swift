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

protocol StockViewModelInputs {
    var initialiseData: PublishRelay<Void> { get }
    var fetchCachedStocks: PublishRelay<Void> { get }
    var fetchStocks: PublishRelay<Void> { get }
    var setAsFavoriteStock: PublishRelay<StockModel> { get }
    var stockSelected: PublishRelay<StockModel> { get }
}

protocol StockViewModelOutputs {
    var dataInitialised: Observable<Void> { get }
    var stocks: Observable<[StockModel]> { get }
    var updatedStock: Observable<StockModel> { get }
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
    let initialiseData = PublishRelay<Void>()
    let fetchCachedStocks = PublishRelay<Void>()
    let fetchStocks = PublishRelay<Void>()
    let setAsFavoriteStock = PublishRelay<StockModel>()
    let stockSelected = PublishRelay<StockModel>()
    
    // Outputs
    let dataInitialised: Observable<Void>
    let stocks: Observable<[StockModel]>
    let updatedStock: Observable<StockModel>
    let showDetail: Driver<StockModel>
    
    private let service: StockService
    private let bag = DisposeBag()
    
    init(service: StockService) {
        self.service = service
        self.dataInitialised = self.initialiseData
            .flatMap({
                service.initialiseData()
            })
        
        let updatedStocks = self.fetchStocks
            .flatMap({ _ -> Observable<[StockModel]> in
                service.fetchStocks()
            })
        
        let cachedStocks = self.fetchCachedStocks
            .flatMap({ _ -> Observable<[StockModel]> in
                Observable.just(service.cachedStock)
            })

        self.stocks = Observable
            .merge([cachedStocks, updatedStocks])
        
        self.updatedStock = self.setAsFavoriteStock
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
