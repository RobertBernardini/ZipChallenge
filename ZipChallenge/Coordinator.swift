//
//  Coordinator.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

/*
 Coorinator used in the app to handle navigation using a Tab Bar Controller.
 The repositories are instantiated in the coordinator and injected into the
 services, which in turn are injected into the view models, and they into
 the view controllers.
*/
protocol Coordinator {
    var tabBarController: UITabBarController { get }
    
    func start()
}

class MainCoordinator {
    var tabBarController: UITabBarController
    private var stocks: [StockModel] = []
    private let dataRepository: DataRepositoryType
    private let cacheRepository: CacheRepositoryType
    private let apiRepository: APIRepositoryType
    private let bag = DisposeBag()
    
    init(
        tabBarController: UITabBarController,
        dataRepository: DataRepositoryType = DataRepository(),
        cacheRepository: CacheRepositoryType = CacheRepository(),
        apiRepository: APIRepositoryType = APIRepository()
    ) {
        self.tabBarController = tabBarController
        self.dataRepository = dataRepository
        self.cacheRepository = cacheRepository
        self.apiRepository = apiRepository
    }
    
    func start() {
        let stockService: StockServiceType = StockService(
            dataRepository: dataRepository,
            cacheRepository: cacheRepository,
            apiRepository: apiRepository)
        let stockViewModel: StockViewModelType = StockViewModel(service: stockService)
        let stockViewController = StockViewController.instantiate(with: stockViewModel)
        let stockImage = UIImage(named: "stock")
        stockViewController.tabBarItem = UITabBarItem(title: "Stocks", image: stockImage, tag: 0)

        let favoriteStockService: FavoriteStockServiceType = FavoriteStockService(
            dataRepository: dataRepository,
            cacheRepository: cacheRepository,
            apiRepository: apiRepository)
        let favoriteStockViewModel = FavoriteStockViewModel(service: favoriteStockService)
        let favoriteStockViewController = FavoriteStockViewController.instantiate(with: favoriteStockViewModel)
        favoriteStockViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)

        let settingsService: SettingsServiceType = SettingsService()
        let settingsViewModel = SettingsViewModel(service: settingsService)
        let settingsViewController = SettingsViewController.instantiate(with: settingsViewModel)
        let settingsImage = UIImage(named: "settings")
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: settingsImage, tag: 2)
        
        let controllers = [stockViewController, favoriteStockViewController, settingsViewController]
        tabBarController.viewControllers = controllers.map({ UINavigationController(rootViewController: $0) })
        
        let showFromStockController = stockViewModel.outputs.showDetail
            .map({ ($0, stockViewController.navigationController) })
        let showFromFavoritesController = favoriteStockViewModel.outputs.showDetail
            .map({ ($0, favoriteStockViewController.navigationController) })
        
        Observable.merge([showFromStockController, showFromFavoritesController])
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { self.showStockDetails(for: $0.0, on: $0.1) })
            .disposed(by: bag)
    }
    
    func showStockDetails(
        for stock: StockModel,
        on navigationController: UINavigationController?
    ) {
        let stockDetailService: StockDetailServiceType = StockDetailService(
            dataRepository: dataRepository,
            cacheRepository: cacheRepository,
            apiRepository: apiRepository)
        let stockDetailViewModel = StockDetailViewModel(service: stockDetailService, stock: stock)
        let stockDetailViewController = StockDetailViewController.instantiate(with: stockDetailViewModel)
        navigationController?.pushViewController(stockDetailViewController, animated: true)
    }
}

extension MainCoordinator: Coordinator {}
