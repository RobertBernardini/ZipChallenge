//
//  FavoriteStockTableViewCell.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import UIKit
import Kingfisher

protocol FavoriteStockTableViewCellDelegate: AnyObject {
    func favoriteStockTableViewCell(_ cell: FavoriteStockTableViewCell, didUpdateFavorite isFavorite: Bool)
}

class FavoriteStockTableViewCell: UITableViewCell {
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var percentageChangeLabel: UILabel!
    @IBOutlet var percentageChangeView: UIView!
    @IBOutlet var favoriteButton: UIButton!
    
    weak var delegate: FavoriteStockTableViewCellDelegate?
    
    typealias DisplayData = StockDisplayable
    var displayData: StockDisplayable? {
        didSet {
            updateView()
        }
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
        delegate?.favoriteStockTableViewCell(self, didUpdateFavorite: sender.isSelected)
    }
}

extension FavoriteStockTableViewCell: ViewDisplayable {}
