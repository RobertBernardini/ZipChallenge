//
//  StockViewController.swift
//  ZipCodeChallenge
//
//  Created by Robert Bernardini on 21/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class StockViewController: UIViewController {
    enum Constants {
        static let stockCellIdentifier = "StockCell"
    }
    
    @IBOutlet var tableView: UITableView!
    
    typealias ViewModel = StockViewModel
    var viewModel: StockViewModel!
    let disposeBag = DisposeBag()
    private var stocks: [StockModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUserInterface()
        bindUserInterface()
    }

    func configureUserInterface() {
        navigationItem.title = "Stocks"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.register(StockTableViewCell.self, forCellReuseIdentifier: Constants.stockCellIdentifier)
    }
    
    func bindUserInterface() {
//        stocks.bind(to: tableView.rx.items(cellIdentifier: Constants.stockCellIdentifier, cellType: StockTableViewCell.self)) { [weak self] row, stock, cell in
//            cell.delegate = self
//            cell.displayData = stock
//            cell.selectionStyle = .none
//        }
//        .disposed(by: disposeBag)
        
        
        
        tableView.rx.modelSelected(StockModel.self)
            .bind(to: viewModel.selectedStock)
            .disposed(by: disposeBag)
    }
    
    func updateFavorite(for stock: StockModel) {
        guard let index = stocks.firstIndex(where: { $0.symbol == stock.symbol }) else { return }
        stocks[index].isFavorite = stock.isFavorite
        let indexPath = IndexPath(row: index, section: 0)
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.endUpdates()
    }
}

extension StockViewController: ViewModelable {}

// Have used traditional way of setting up tableview as it allows more control over updating just
// one cell of the tableview. If I bind the stocks behavior relay to the table view every time
// I update it it will refresh the whole table when I may just want to update one cell.
extension StockViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.stockCellIdentifier,
            for: indexPath) as? StockTableViewCell else { return UITableViewCell() }
        cell.delegate = self
        cell.displayData = stocks[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}

extension StockViewController: StockTableViewCellDelegate {
    func stockTableViewCell(
        _ cell: StockTableViewCell,
        didSetStockWithSymbol symbol: String,
        asFavorite isFavorite: Bool
    ) {
        guard var stock = stocks.first(where: { $0.stockSymbol == symbol }) else { return }
        stock.isFavorite = true
        viewModel.setAsFavoriteStock.accept(stock)
    }
}
