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

/*
 View Controller that displays the list of stocks to the user.
 It is a sub-class of Base Stock View Controller.
 Rx is used to update data coming in from the view model and to send signals
 to the view model to fetch data.
 The fetching of the profile data only occurs once the table view has stopped
 scrolling.
 */
final class StockViewController: BaseStockViewController {
    typealias ViewModel = StockViewModelType
    var viewModel: StockViewModelType!
    
    private lazy var refreshHandler: RefreshHandler = {
        RefreshHandler(view: tableView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUserInterface()
        bindUserInterface()
        viewModel.inputs.initializeData.accept(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.fetchCachedStocks.accept(())
    }

    override func configureUserInterface() {
        super.configureUserInterface()
        navigationItem.title = "Stocks"
    }
    
    func bindUserInterface() {
        // Refresh handler
        refreshHandler.refresh
            .bind(to: viewModel.inputs.fetchStocks)
            .disposed(by: bag)
        
        // Selected stock to see detail
        tableView.rx.itemSelected
            .map({ [unowned self] in
                return self.stocks[$0.row]
            })
            .bind(to: viewModel.inputs.stockSelected)
            .disposed(by: bag)
        
        // Bindings in order to detect when table stops scrolling and
        // fetch profile data
        tableView.rx.willDisplayCell
            .map({ [unowned self] cellTuple -> Void in
                let stock = self.stocks[cellTuple.indexPath.row]
                self.stocksInView.append(stock)
            })
            .subscribe()
            .disposed(by: bag)
        
        tableView.rx.didEndDisplayingCell
            .map({ [unowned self] cellTuple -> Void in
                let stock = self.stocks[cellTuple.indexPath.row]
                guard let index = self.stocksInView.firstIndex(of: stock) else { return }
                self.stocksInView.remove(at: index)
            })
            .subscribe()
            .disposed(by: bag)
        
        let fetchProfiles = PublishRelay<[StockModel]>()
        tableView.rx.didEndDragging
            .map({ [unowned self] decelerating -> Void in
                if decelerating == false {
                    fetchProfiles.accept(self.stocksInView)
                }
            })
            .asObservable()
            .subscribe()
            .disposed(by: bag)

        let didEndDecelerating = tableView.rx.didEndDecelerating
            .map({ [unowned self] in self.stocksInView })
            .asObservable()
        
        let didScrollToTop = tableView.rx.didScrollToTop
            .map({ [unowned self] in self.stocksInView })
            .asObservable()

        Observable.merge(
            [fetchProfiles.asObservable(),
             didEndDecelerating,
             didScrollToTop])
            .bind(to: viewModel.inputs.fetchProfiles)
            .disposed(by: bag)
        
        // Fetch stocks after data initialised
        viewModel.outputs.dataInitialized
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.viewModel.inputs.fetchCachedStocks.accept(())
                self?.viewModel.inputs.fetchStocks.accept(())
            })
            .disposed(by: bag)
        
        // Update table and set stocks
        viewModel.outputs.stocks
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.refreshHandler.end()
                switch $0 {
                case .success(let stock):
                    self.stocks = stock
                    self.tableView.reloadData()
                    // Fire signal to fetch stock profiles when the data is first loaded.
                    // A delay is needed so that the persistant data has time to load.
                    let delay = DispatchTime.now() + 1
                    DispatchQueue.main.asyncAfter(deadline: delay) {
                        fetchProfiles.accept(self.stocksInView)
                    }
                case .failure(let error):
                    self.viewModel.inputs.fetchCachedStocks.accept(())
                    if let error = error as? URLError, error.code == .notConnectedToInternet {
                        self.showErrorAlert(error: APIError.internet)
                    }
                }
            })
            .disposed(by: bag)
        
        // Update stocks
        viewModel.outputs.updatedStocks
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                switch $0 {
                case .success(let stocks):
                    self?.update(with: stocks)
                    self?.reloadCells(for: stocks)
                case .failure: break
                }
            })
            .disposed(by: bag)
        
        // Update favorite stock
        viewModel.outputs.updatedFavoriteStock
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
