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

final class StockViewController: BaseStockViewController {
    @IBOutlet var loadingView: UIActivityIndicatorView!
    
    typealias ViewModel = StockViewModel
    var viewModel: StockViewModel!
    
    private lazy var refreshHandler: RefreshHandler = {
        RefreshHandler(view: tableView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUserInterface()
        bindUserInterface()
        viewModel.inputs.initialiseData.accept(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.fetchCachedStocks.accept(())
        loadingView.startAnimating()
    }

    override func configureUserInterface() {
        super.configureUserInterface()
        navigationItem.title = "Stocks"
        tableView.isHidden = true
    }
    
    func bindUserInterface() {
        refreshHandler.refresh
            .startWith(())
            .bind(to: viewModel.inputs.fetchStocks)
            .disposed(by: bag)
        
        tableView.rx.itemSelected
            .map({ [unowned self] in
                return self.stocks[$0.row]
            })
            .bind(to: viewModel.inputs.stockSelected)
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
                self?.refreshHandler.end()
                self?.loadingView.stopAnimating()
                self?.loadingView.isHidden = true
                self?.showErrorAlert(error: error)
                self?.tableView.isHidden = false
            })
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                self?.refreshHandler.end()
                self?.loadingView.stopAnimating()
                self?.stocks = $0
                self?.tableView.reloadData()
                self?.tableView.isHidden = ($0.count == 0)
            })
            .disposed(by: bag)
        
        viewModel.outputs.updatedStocks
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                self?.update(with: $0)
                self?.reloadCells(for: $0)
            })
            .disposed(by: bag)

        viewModel.outputs.favoriteStock
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                self?.update(with: [$0])
            })
            .disposed(by: bag)
    }
    
    override func updateAsFavorite(stock: StockModel) {
        viewModel.inputs.setAsFavoriteStock.accept(stock)
    }
}

extension StockViewController: ViewModelable {}

// Have used traditional way of setting up tableview as it allows more control over updating just
// one cell of the tableview. If I bind the stocks behavior relay to the table view every time
// I update it it will refresh the whole table when I may just want to update one cell.
