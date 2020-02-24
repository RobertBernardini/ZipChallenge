//
//  StockDetailViewModel.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

protocol StockDetailViewModel {
    
}

class ZipStockDetailViewModel {
    private let service: StockDetailService
    private let stock: StockModel
    
    init(service: StockDetailService, stock: StockModel) {
        self.service = service
        self.stock = stock
    }
}

extension ZipStockDetailViewModel: StockDetailViewModel {}
