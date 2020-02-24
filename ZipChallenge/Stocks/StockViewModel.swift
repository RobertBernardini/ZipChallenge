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

protocol StockViewModel {
    // Inputs
    var fetchSavedStocks: PublishRelay<Void> { get }
    var fetchStocks: PublishRelay<Void> { get }
    var setAsFavoriteStock: PublishRelay<StockModel> { get }
    var selectedStock: PublishRelay<StockModel> { get }
    
    // Outputs
    var stocks: Observable<[StockModel]> { get }
    var updatedStock: Observable<StockModel> { get }
    var showDetail: Observable<StockModel> { get }
}

class ZipStockViewModel {
    // Inputs
    var fetchSavedStocks = PublishRelay<Void>()
    var fetchStocks = PublishRelay<Void>()
    var setAsFavoriteStock = PublishRelay<StockModel>()
    var selectedStock = PublishRelay<StockModel>()
    
    // Outputs
    var stocks: Observable<[StockModel]>
    var updatedStock: Observable<StockModel>
    var showDetail: Observable<StockModel>
    
    private let service: StockService
    private let disposeBag = DisposeBag()
    
    init(service: StockService) {
        self.service = service
        
        let apiStocks = self.fetchStocks
            .flatMap({ _ -> Observable<[StockModel]> in
                service.fetchStocks()
            })
        
        let savedStocks = self.fetchSavedStocks
            .flatMap({ _ -> Observable<[StockModel]> in
                service.fetchSavedStocks()
            })

        let fetchedStocks = Observable.merge([savedStocks, apiStocks])

        
        self.fetchedStocks = fetchedStocks

        self.updatedStock = self.setAsFavoriteStock
            
    }
}

extension ZipStockViewModel: StockViewModel {}
