//
//  StockDetailView.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import UIKit

class StockDetailView: UIView {
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var sectorLabel: UILabel!
    @IBOutlet var industryLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var changesLabel: UILabel!
    @IBOutlet var percentageChangeLabel: UILabel!
    @IBOutlet var percentageChangeView: UIView!
    @IBOutlet var lastDividendLabel: UILabel!
    
    typealias DisplayData = StockDetailDisplayable
    var displayData: StockDetailDisplayable? {
        didSet { updateView() }
    }
    
    func updateView() {
        guard let data = displayData else {
            logoImage.image = nil
            symbolLabel.text = ""
            nameLabel.text = ""
            sectorLabel.text = ""
            industryLabel.text = ""
            priceLabel.text = ""
            changesLabel.text = ""
            percentageChangeLabel.text = ""
            percentageChangeView.backgroundColor = .clear
            lastDividendLabel.text = ""
            return
        }
        logoImage.kf.setImage(with: data.stockCompanyLogo)
        symbolLabel.text = data.stockSymbol
        nameLabel.text = data.stockName
        sectorLabel.text = data.stockSector
        industryLabel.text = data.stockIndustry
        priceLabel.text = data.stockPrice
        changesLabel.text = data.stockChanges
        percentageChangeLabel.text = data.stockPercentageChange
        percentageChangeView.backgroundColor = data.isStockPercentageChangePositive ? .green : .red
        lastDividendLabel.text = data.stockLastDividend
    }
}

extension StockDetailView: ViewDisplayable {}
