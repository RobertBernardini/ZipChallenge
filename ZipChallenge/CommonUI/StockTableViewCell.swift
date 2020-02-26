//
//  StocksTableViewCell.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import UIKit
import Kingfisher

protocol StockTableViewCellDelegate: AnyObject {
    func stockTableViewCell(
        _ cell: StockTableViewCell,
        didSetStockWithSymbol symbol: String,
        asFavorite isFavorite: Bool
    )
}

class StockTableViewCell: UITableViewCell {
    enum Constants {
        static let stockCellName = "StockTableViewCell"
        static let stockCellIdentifier = "StockCell"
    }
    
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var percentageChangeLabel: UILabel!
    @IBOutlet var percentageChangeView: UIView!
    @IBOutlet var favoriteButton: UIButton!
    
    weak var delegate: StockTableViewCellDelegate?
    
    typealias DisplayData = StockDisplayable
    var displayData: StockDisplayable? {
        didSet { updateView() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        percentageChangeView.layer.cornerRadius = 5
        logoImage.layer.cornerRadius = 5
        favoriteButton.layer.cornerRadius = 5
    }
    
    func updateView() {
        guard let data = displayData else {
            logoImage.image = nil
            symbolLabel.text = ""
            nameLabel.text = ""
            priceLabel.text = ""
            percentageChangeLabel.text = ""
            percentageChangeView.backgroundColor = .clear
            favoriteButton.isSelected = false
            return
        }
        logoImage.kf.setImage(with: data.stockCompanyLogo)
        symbolLabel.text = data.stockSymbol
        nameLabel.text = data.stockName
        priceLabel.text = data.stockPrice
        percentageChangeLabel.text = data.stockPercentageChange
        percentageChangeView.backgroundColor = data.isStockPercentageChangePositive ? .green : .red
        favoriteButton.isSelected = data.isFavoriteStock
    }
    
    @IBAction func didTapFavorite(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let symbol = displayData?.stockSymbol ?? ""
        delegate?.stockTableViewCell(self, didSetStockWithSymbol: symbol, asFavorite: sender.isSelected)
    }
}

extension StockTableViewCell: ViewDisplayable {}
