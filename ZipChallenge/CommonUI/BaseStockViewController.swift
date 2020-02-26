//
//  BaseStockViewController.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 26/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BaseStockViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    var stocks: [StockModel] = []
    let bag = DisposeBag()
    
    func configureUserInterface() {
        navigationItem.title = "Stocks"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.rowHeight = 150
        tableView.dataSource = self
        let nib = UINib(nibName: StockTableViewCell.Constants.stockCellName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: StockTableViewCell.Constants.stockCellIdentifier)
    }

    func update(with updatedStocks: [StockModel]) {
        updatedStocks.forEach({ updatedStock in
            if let index = stocks.indexes(of: updatedStock).first {
                stocks[index].update(with: updatedStock)
            }
        })
    }
    
    func reloadCells(for updatedStocks: [StockModel]) {
        let indexPaths = updatedStocks
            .map({ stocks.indexes(of: $0).first })
            .compactMap({ $0 })
            .map({ IndexPath(row: $0, section: 0) })
        tableView.beginUpdates()
        tableView.reloadRows(at: indexPaths, with: .none)
        tableView.endUpdates()
    }
        
    // Function to be called by delegate overriden in child classes
    func updateAsFavorite(stock: StockModel) {}
}

extension BaseStockViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StockTableViewCell.Constants.stockCellIdentifier,
            for: indexPath) as? StockTableViewCell else { return UITableViewCell() }
        cell.delegate = self
        cell.displayData = stocks[indexPath.row]
        return cell
    }
}

extension BaseStockViewController: StockTableViewCellDelegate {
    func stockTableViewCell(
        _ cell: StockTableViewCell,
        didSetStockWithSymbol symbol: String,
        asFavorite isFavorite: Bool
    ) {
        guard var stock = stocks.first(where: { $0.stockSymbol == symbol }) else { return }
        stock.isFavorite = isFavorite
        updateAsFavorite(stock: stock)
    }
}
