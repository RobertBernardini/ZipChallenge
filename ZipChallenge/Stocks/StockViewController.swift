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
 */
final class StockViewController: BaseStockViewController {
    typealias ViewModel = StockViewModel
    var viewModel: StockViewModel!
    
    private lazy var refreshHandler: RefreshHandler = {
        RefreshHandler(view: tableView)
    }()
    private var stocksInView: [StockModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUserInterface()
        bindUserInterface()
        viewModel.inputs.initialiseData.accept(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.fetchCachedStocks.accept(())
        if Connectivity.isConnectedToInternet == false { showErrorAlert(error: APIError.internet) }
    }

    override func configureUserInterface() {
        super.configureUserInterface()
        navigationItem.title = "Stocks"
    }
    
    func bindUserInterface() {
        refreshHandler.refresh
            .do(onNext: { [unowned self] in
                guard Connectivity.isConnectedToInternet == false else { return }
                self.showErrorAlert(error: APIError.internet)
            })
            .bind(to: viewModel.inputs.fetchStocks)
            .disposed(by: bag)
        
        tableView.rx.itemSelected
            .map({ [unowned self] in
                return self.stocks[$0.row]
            })
            .bind(to: viewModel.inputs.stockSelected)
            .disposed(by: bag)
        
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
        
        let fetchProfilesSubject = PublishRelay<[StockModel]>()
        tableView.rx.didEndDragging
            .map({ [unowned self] decelerating -> Void in
                if decelerating == false {
                    fetchProfilesSubject.accept(self.stocksInView)
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
            [fetchProfilesSubject.asObservable(),
             didEndDecelerating,
             didScrollToTop])
            .map({ stocks -> [[StockModel]] in
                let stocksToUpdate = stocks.filter({ $0.hasProfileData == false })
                return stocksToUpdate.toChunks(of: 3)
            })
            .asObservable()
            .subscribe(onNext: {
                $0.forEach({ [weak self] in
                    self?.viewModel.inputs.fetchProfiles.accept($0)
                })
            })
            .disposed(by: bag)
        
        viewModel.outputs.dataInitialised
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.viewModel.inputs.fetchCachedStocks.accept(())
                self?.viewModel.inputs.fetchStocks.accept(())
            })
            .disposed(by: bag)
        
        viewModel.outputs.stocks
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.refreshHandler.end()
                self.stocks = $0
                self.tableView.reloadData()
                
                // Fire signal to fetch stock profiles when the data is first loaded.
                // A delay is needed so that the persistant data has time to load.
                let delay = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: delay) {
                    fetchProfilesSubject.accept(self.stocksInView)
                }
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
