//
//  FavoriteStockViewController.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class FavoriteStockViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    typealias ViewModel = FavoriteStockViewModel
    var viewModel: FavoriteStockViewModel!
    
    private var favoriteStocks: [StockModel] = []
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUserInterface()
        bindUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.fetchFavoriteStocks.accept(())
        viewModel.inputs.startUpdates.accept(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.inputs.stopUpdatesAndSave.accept(favoriteStocks)
    }
    
    func configureUserInterface() {
        navigationItem.title = "Favourite Stocks"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        let nib = UINib(nibName: StockTableViewCell.Constants.stockCellName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: StockTableViewCell.Constants.stockCellIdentifier)
    }
    
    func bindUserInterface() {
        viewModel.outputs.favoriteStocks
            .drive(onNext: { [weak self] in
                self?.favoriteStocks = $0
                self?.tableView.reloadData()
            })
            .disposed(by: bag)
        
        viewModel.outputs.updatedStock
            .drive(onNext: { [weak self] in
                self?.remove(stock: $0)
            })
            .disposed(by: bag)
        
        tableView.rx.itemSelected
            .map({ [unowned self] in
                return self.favoriteStocks[$0.row]
            })
            .bind(to: viewModel.inputs.stockSelected)
            .disposed(by: bag)
    }

    func remove(stock: StockModel) {
        guard let index = favoriteStocks.firstIndex(where: { $0.symbol == stock.symbol }) else { return }
        favoriteStocks.remove(at: index)
        let indexPath = IndexPath(row: index, section: 0)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .right)
        tableView.endUpdates()
    }
}

extension FavoriteStockViewController: ViewModelable {}

// Have used traditional way of setting up tableview as it allows more control over updating just
// one cell of the tableview. If I bind the stocks behavior relay to the table view every time
// I update it it will refresh the whole table when I may just want to update one cell.
extension FavoriteStockViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteStocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StockTableViewCell.Constants.stockCellIdentifier,
            for: indexPath) as? StockTableViewCell else { return UITableViewCell() }
        cell.delegate = self
        cell.displayData = favoriteStocks[indexPath.row]
        return cell
    }
}

extension FavoriteStockViewController: StockTableViewCellDelegate {
    func stockTableViewCell(
        _ cell: StockTableViewCell,
        didSetStockWithSymbol symbol: String,
        asFavorite isFavorite: Bool
    ) {
        guard var stock = favoriteStocks.first(where: { $0.stockSymbol == symbol }) else { return }
        stock.isFavorite = isFavorite
        viewModel.inputs.setAsFavoriteStock.accept(stock)
    }
}
