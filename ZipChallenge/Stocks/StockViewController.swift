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
    @IBOutlet var tableView: UITableView!
    @IBOutlet var loadingView: UIActivityIndicatorView!
    
    typealias ViewModel = StockViewModel
    var viewModel: StockViewModel!
    
    private var stocks: [StockModel] = []
    private let bag = DisposeBag()
    private lazy var refreshHandler: RefreshHandler = {
        RefreshHandler(view: tableView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUserInterface()
        bindUserInterface()
        viewModel.inputs.initialiseData.accept(())
        loadingView.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.fetchCachedStocks.accept(())
    }

    func configureUserInterface() {
        tableView.isHidden = true
        navigationItem.title = "Stocks"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.rowHeight = 150
        tableView.dataSource = self
        let nib = UINib(nibName: StockTableViewCell.Constants.stockCellName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: StockTableViewCell.Constants.stockCellIdentifier)
    }
    
    func bindUserInterface() {
        refreshHandler.refresh
            .startWith(())
            .bind(to: viewModel.inputs.fetchStocks)
            .disposed(by: bag)
        
        viewModel.outputs.dataInitialised
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.viewModel.inputs.fetchCachedStocks.accept(())
                self?.viewModel.inputs.fetchStocks.accept(())
            })
            .disposed(by: bag)
        
        viewModel.outputs.stocks
            .do( onError: { [weak self] error in
                self?.showErrorAlert(error: error)
            })
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] in
                self?.refreshHandler.end()
                self?.loadingView.stopAnimating()
                self?.stocks = $0
                self?.tableView.reloadData()
                self?.tableView.isHidden = ($0.count == 0)
            })
            .disposed(by: bag)
        
        viewModel.outputs.updatedStock
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                self?.updateStocks(for: $0)
            })
            .disposed(by: bag)
        
        tableView.rx.itemSelected
            .map({ [unowned self] in
                return self.stocks[$0.row]
            })
            .bind(to: viewModel.inputs.stockSelected)
            .disposed(by: bag)
    }
    
    func updateStocks(for stock: StockModel) {
        guard let index = stocks.firstIndex(where: { $0.symbol == stock.symbol }) else { return }
        stocks[index].isFavorite = stock.isFavorite
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
            withIdentifier: StockTableViewCell.Constants.stockCellIdentifier,
            for: indexPath) as? StockTableViewCell else { return UITableViewCell() }
        cell.delegate = self
        cell.displayData = stocks[indexPath.row]
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
        stock.isFavorite = isFavorite
        viewModel.inputs.setAsFavoriteStock.accept(stock)
    }
}
