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

/*
 View model that manages the requests of the Favorite Stock View Controller
 and returns the required data to be displayed. It uses Rx to bind signals
 and observers.
*/
protocol FavoriteStockViewModelInputs {
    var startUpdates: PublishRelay<Void> { get }
    var stopUpdates: PublishRelay<Void> { get }
    var fetchFavoriteStocks: PublishRelay<Void> { get }
    var fetchProfiles: PublishRelay<[StockModel]> { get }
    var removeFavoriteStock: PublishRelay<StockModel> { get }
    var stockSelected: PublishRelay<StockModel> { get }
}

protocol FavoriteStockViewModelOutputs {
    var favoriteStocks: Observable<[StockModel]> { get }
    var updatedStocks: Observable<Result<[StockModel], Error>> { get }
    var removedFavoriteStock: Observable<StockModel> { get }
    var showDetail: Observable<StockModel> { get }
}

protocol FavoriteStockViewModelType {
    var inputs: FavoriteStockViewModelInputs { get }
    var outputs: FavoriteStockViewModelOutputs { get }
}

class FavoriteStockViewModel {
    var inputs: FavoriteStockViewModelInputs { self }
    var outputs: FavoriteStockViewModelOutputs { self }
    
    // Inputs
    let startUpdates = PublishRelay<Void>()
    let stopUpdates = PublishRelay<Void>()
    let fetchFavoriteStocks = PublishRelay<Void>()
    let fetchProfiles = PublishRelay<[StockModel]>()
    let removeFavoriteStock = PublishRelay<StockModel>()
    let stockSelected = PublishRelay<StockModel>()
    
    // Outputs
    let favoriteStocks: Observable<[StockModel]>
    let updatedStocks: Observable<Result<[StockModel], Error>>
    let removedFavoriteStock: Observable<StockModel>
    let showDetail: Observable<StockModel>
    
    private let service: FavoriteStockServiceType
    private let bag = DisposeBag()
    
    init(service: FavoriteStockServiceType) {
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
        
        self.stopUpdates
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: {
                timer?.invalidate()
                timer = nil
            })
            .disposed(by: bag)
        
        self.favoriteStocks = self.fetchFavoriteStocks
            .flatMap({ _ -> Observable<[StockModel]> in
                Observable.just(service.cachedFavoriteStock)
            })
        
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
        
        let updatedProfiles = fetchStockProfiles
            .flatMap({ stocks -> Observable<Result<[StockModel], Error>> in
                return service.fetchStockProfiles(for: stocks)
            })
        
        let updatedPrices = fetchPrices
            .flatMap({ _ -> Observable<Result<[StockModel], Error>> in
                let stocks = service.cachedFavoriteStock
                return service.fetchPrices(for: stocks)
            })
        
        self.updatedStocks = Observable.merge([updatedProfiles, updatedPrices])
        
        self.removedFavoriteStock = self.removeFavoriteStock
            .flatMap({ stock -> Observable<StockModel> in
                service.updateAsFavorite(stock: stock)
                return Observable.just(stock)
            })
            
        self.showDetail = self.stockSelected.asObservable()
    }
}

extension FavoriteStockViewModel: FavoriteStockViewModelType {}
extension FavoriteStockViewModel: FavoriteStockViewModelInputs {}
extension FavoriteStockViewModel: FavoriteStockViewModelOutputs {}
