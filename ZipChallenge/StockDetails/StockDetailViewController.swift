//
//  StockDetailViewController.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/*
 View Controller that displays the details of the stock.
 Rx is used to update data coming in from the view model and to send signals
 to the view model to fetch data.
 The price data is updated every 15 seconds.
 The historical price data is fetched once the view loads only once.
 An internet connection is needed to use collect the historical data.
*/
final class StockDetailViewController: UIViewController {
    @IBOutlet var detailView: StockDetailView!
    @IBOutlet var priceChartView: StockDetailPriceChartView!
    
    typealias ViewModel = StockDetailViewModel
    var viewModel: StockDetailViewModel!
    
    private var stock: StockModel?
    private var historicalPrices: [StockDetailHistorical] = []
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        stock = viewModel.outputs.stock
        configureUserInterface()
        bindUserInterface()
        viewModel.inputs.startUpdates.accept(())
        viewModel.inputs.fetchPriceHistory.accept(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Connectivity.isConnectedToInternet == false { showErrorAlert(error: APIError.internet) }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let stock = stock else { return }
        viewModel.inputs.stopUpdatesAndSave.accept(stock)
    }
    
    func configureUserInterface() {
        navigationItem.title = "Stock Details"
        detailView.displayData = stock
        priceChartView.delegate = self
    }
    
    func bindUserInterface() {
        viewModel.outputs.updatedStock
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                self?.stock = $0
                self?.detailView.displayData = $0
            })
            .disposed(by: bag)
        
        viewModel.outputs.historicalPrices
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                self?.historicalPrices = $0
                let duration = PriceChartPeriod.threeMonths
                guard let historicals = self?.historicalPrices($0, from: duration.startDate) else { return }
                let priceChartData = PriceChartData(duration: duration, historicalPrices: historicals)
                self?.priceChartView.displayData = priceChartData
            })
            .disposed(by: bag)
    }
}

extension StockDetailViewController {
    private func historicalPrices(_ historicals: [StockDetailHistorical], from startDate: Date) -> [StockDetailHistorical]? {
        var newHistoricals = historicals
        newHistoricals.removeAll(where: { $0.stockDate < startDate })
        return newHistoricals
    }
    
    private func showPriceHistoryActionSheet(
        with title: String?,
        message: String?,
        handler: @escaping ((PriceChartPeriod) -> Void)
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        PriceChartPeriod.allCases.forEach { option in
            let action = UIAlertAction(title: option.text, style: .default) { _ in
                handler(option)
            }
            alert.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}


extension StockDetailViewController: ViewModelable {}

extension StockDetailViewController: StockDetailPriceChartViewDelegate {
    func stockDetailPriceHistoryViewDidTapUpdateDuration(_ view: StockDetailPriceChartView) {
        showPriceHistoryActionSheet(
            with: PriceChartPeriod.title,
            message: PriceChartPeriod.message
        ) { [unowned self] duration in
            guard let historicals = self.historicalPrices(self.historicalPrices, from: duration.startDate) else { return }
            let priceChartData = PriceChartData(duration: duration, historicalPrices: historicals)
            self.priceChartView.displayData = priceChartData
        }
    }
}
