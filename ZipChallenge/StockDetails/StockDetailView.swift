//
//  StockDetailView.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import UIKit

/*
 View that displays the stock data.
 */
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        logoImage.layer.cornerRadius = 10
        percentageChangeView.backgroundColor = .clear
        percentageChangeView.layer.cornerRadius = 5
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
        let logoURL = URL(string: data.stockCompanyLogo)
        logoImage.kf.setImage(with: logoURL)
        symbolLabel.text = data.stockSymbol
        nameLabel.text = data.stockName
        sectorLabel.text = data.stockSector
        industryLabel.text = data.stockIndustry
        priceLabel.text = data.stockPrice
        changesLabel.text = data.stockChanges
        percentageChangeLabel.text = data.stockPercentageChange
        percentageChangeView.backgroundColor = data.stockPercentageChangeColor
        lastDividendLabel.text = data.stockLastDividend
    }
}

extension StockDetailView: ViewDisplayable {}
