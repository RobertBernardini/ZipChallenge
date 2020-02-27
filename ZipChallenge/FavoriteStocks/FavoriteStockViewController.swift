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

/*
 View Controller that displays the list of favourite.
 It is a sub-class of Base Stock View Controller.
 Rx is used to update data coming in from the view model and to send signals
 to the view model to fetch data.
 It functions much like Stock View Controller but only for favourite stocks.
 It also does not fetch the stock profile, that is left to the Stock View
 Controller which is then stored in cache.
 The price data is updated every 15 seconds.
*/
final class FavoriteStockViewController: BaseStockViewController {
    typealias ViewModel = FavoriteStockViewModel
    var viewModel: FavoriteStockViewModel!

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
        viewModel.inputs.stopUpdatesAndSave.accept(stocks)
    }
    
    override func configureUserInterface() {
        super.configureUserInterface()
        navigationItem.title = "Favourite Stocks"
    }
    
    func bindUserInterface() {
        tableView.rx.itemSelected
            .map({ [unowned self] in
                return self.stocks[$0.row]
            })
            .bind(to: viewModel.inputs.stockSelected)
            .disposed(by: bag)
        
        viewModel.outputs.favoriteStocks
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                self?.stocks = $0
                self?.tableView.reloadData()
            })
            .disposed(by: bag)
        
        viewModel.outputs.updatedStocks
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                self?.update(with: $0)
                self?.reloadCells(for: $0)
            })
            .disposed(by: bag)

        viewModel.outputs.removedStock
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                self?.remove(stock: $0)
            })
            .disposed(by: bag)
    }

    func remove(stock: StockModel) {
        guard let index = stocks.firstIndex(of: stock) else { return }
        stocks.remove(at: index)
        let indexPath = IndexPath(row: index, section: 0)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .right)
        tableView.endUpdates()
    }
    
    override func updateAsFavorite(stock: StockModel) {
        viewModel.inputs.removeFromFavoriteStock.accept(stock)
    }
}

extension FavoriteStockViewController: ViewModelable {}
