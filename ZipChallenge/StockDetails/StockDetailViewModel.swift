//
//  StockDetailViewModel.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/*
 View model that manages the requests of the Stock Detail View Controller
 and returns the required data to be displayed. It uses Rx to bind signals
 and observers.
*/
protocol StockDetailViewModelInputs {
    var startUpdates: PublishRelay<Void> { get }
    var stopUpdates: PublishRelay<Void> { get }
    var fetchPriceHistory: PublishRelay<Void> { get }
}

protocol StockDetailViewModelOutputs {
    var stock: StockModel { get }
    var updatedStock: Observable<StockModel> { get }
    var historicalPrices: Observable<[StockDetailHistorical]> { get }
}

protocol StockDetailViewModel {
    var inputs: StockDetailViewModelInputs { get }
    var outputs: StockDetailViewModelOutputs { get }
}

class ZipStockDetailViewModel {
    var inputs: StockDetailViewModelInputs { self }
    var outputs: StockDetailViewModelOutputs { self }
    
    // Inputs
    let startUpdates = PublishRelay<Void>()
    let stopUpdates = PublishRelay<Void>()
    let fetchPriceHistory = PublishRelay<Void>()
    
    // Outputs
    let stock: StockModel
    let updatedStock: Observable<StockModel>
    let historicalPrices: Observable<[StockDetailHistorical]>
    
    private let service: StockDetailService
    private let bag = DisposeBag()
    
    init(service: StockDetailService, stock: StockModel) {
        self.service = service
        self.stock = stock
        
        let fetchPrice = PublishRelay<Void>()
        var timer: Timer? = nil
            
        self.startUpdates
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: {
                timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
                    fetchPrice.accept(())
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
        
        self.updatedStock = fetchPrice
            .flatMap({ _ -> Observable<StockModel> in
                return service.fetchPrice(for: stock)
            })
        
        self.historicalPrices = self.fetchPriceHistory
            .flatMap({ _ -> Observable<[StockDetailHistorical]> in
                return service.fetchPriceHistory(for: stock)
            })
    }
}

extension ZipStockDetailViewModel: StockDetailViewModel {}
extension ZipStockDetailViewModel: StockDetailViewModelInputs {}
extension ZipStockDetailViewModel: StockDetailViewModelOutputs {}
