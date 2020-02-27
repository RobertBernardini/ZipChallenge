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
        // I originally had code to update each row but it was causing animation conflicts
        // when updating the cell with profile data and whilst scrolling at the same time
        // so the only way to avoid this was by reloading the whole table. Since I only reload
        // when fetching new profile data it should not reload when it already contains data.
        tableView.reloadData()
    }
        
    // Function to be called by delegate overriden in child classes
    func updateAsFavorite(stock: StockModel) {}
}

// Have used traditional way of setting up tableview as it allows more control over updating just
// one cell of the tableview rather than using Rx. If I bind the stocks behavior relay to the table
// view every time I update it it will refresh the whole table when I may just want to update one cell.
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
