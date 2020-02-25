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

protocol StockDetailViewModelInputs {
    var startUpdates: PublishRelay<Void> { get }
    var stopUpdatesAndSave: PublishRelay<StockModel> { get }
    var fetchPrice: PublishRelay<Void> { get }
    var fetchPriceHistory: PublishRelay<Void> { get }
}

protocol StockDetailViewModelOutputs {
    var updatedStock: Driver<StockModel> { get }
    var historicalPrices: Driver<[StockDetailHistorical]> { get }
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
    let stopUpdatesAndSave = PublishRelay<StockModel>()
    let fetchPrice = PublishRelay<Void>()
    let fetchPriceHistory = PublishRelay<Void>()
    
    // Outputs
    let updatedStock: Driver<StockModel>
    let historicalPrices: Driver<[StockDetailHistorical]>
    
    private let service: StockDetailService
    private let bag = DisposeBag()
    private let stock: StockModel
    
    init(service: StockDetailService, stock: StockModel) {
        self.service = service
        self.stock = stock
        
        let fetchPrice = self.fetchPrice
        var timer: Timer? = nil
            
        self.startUpdates
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: {
                timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
                    fetchPrice.accept(())
                }
            })
            .disposed(by: bag)
        
        self.stopUpdatesAndSave
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: {
                timer?.invalidate()
                timer = nil
                service.save(stock: $0)
            })
            .disposed(by: bag)
        
        self.updatedStock = self.fetchPrice
            .flatMap({ _ -> Observable<StockModel> in
                return service.fetchPrice(for: stock)
            })
            .asDriver(onErrorDriveWith: .empty())
        
        self.historicalPrices = self.fetchPriceHistory
            .flatMap({ _ -> Observable<[StockDetailHistorical]> in
                return service.fetchPriceHistory(for: stock)
            })
            .asDriver(onErrorJustReturn: [])
    }
}

extension ZipStockDetailViewModel: StockDetailViewModel {}
extension ZipStockDetailViewModel: StockDetailViewModelInputs {}
extension ZipStockDetailViewModel: StockDetailViewModelOutputs {}
