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

protocol Coordinator {
    var tabBarController: UITabBarController { get }
    
    func start()
}

class MainCoordinator {
    var tabBarController: UITabBarController
    private var stocks: [StockModel] = []
    private let dataRepository: DataRepository
    private let cacheRepository: CacheRepository
    private let apiRepository: APIRepository
    private let bag = DisposeBag()
    
    init(
        tabBarController: UITabBarController,
        dataRepository: DataRepository = ZipDataRepository(),
        cacheRepository: CacheRepository = ZipCacheRepository(),
        apiRepository: APIRepository = ZipAPIRepository()
    ) {
        self.tabBarController = tabBarController
        self.dataRepository = dataRepository
        self.cacheRepository = cacheRepository
        self.apiRepository = apiRepository
    }
    
    func start() {
        let stockService: StockService = ZipStockService(
            dataRepository: dataRepository,
            cacheRepository: cacheRepository,
            apiRepository: apiRepository)
        let stockViewModel: StockViewModel = ZipStockViewModel(service: stockService)
        let stockViewController = StockViewController.instantiate(with: stockViewModel)
        let stockImage = UIImage(named: "stock")
        stockViewController.tabBarItem = UITabBarItem(title: "Stocks", image: stockImage, tag: 0)

        let favoriteStockService: FavoriteStockService = ZipFavoriteStockService(
            dataRepository: dataRepository,
            cacheRepository: cacheRepository,
            apiRepository: apiRepository)
        let favoriteStockViewModel = ZipFavoriteStockViewModel(service: favoriteStockService)
        let favoriteStockViewController = FavoriteStockViewController.instantiate(with: favoriteStockViewModel)
        favoriteStockViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        
        let settingsService: SettingsService = ZipSettingsService()
        let settingsViewModel = ZipSettingsViewModel(service: settingsService)
        let settingsViewController = SettingsViewController.instantiate(with: settingsViewModel)
        let settingsImage = UIImage(named: "settings")
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: settingsImage, tag: 2)
        
        let controllers = [stockViewController, favoriteStockViewController, settingsViewController]
        tabBarController.viewControllers = controllers.map({ UINavigationController(rootViewController: $0) })
        
        let showFromStockController = stockViewModel.outputs.showDetail
            .map({ ($0, stockViewController.navigationController) })
        let showFromFavoritesController = favoriteStockViewModel.outputs.showDetail
            .map({ ($0, favoriteStockViewController.navigationController) })
        
        Driver.merge([showFromStockController, showFromFavoritesController])
            .drive(onNext: {
                self.showStockDetails(for: $0.0, on: $0.1)
            })
        .disposed(by: bag)
    }
    
    func showStockDetails(
        for stock: StockModel,
        on navigationController: UINavigationController?
    ) {
        let stockDetailService: StockDetailService = ZipStockDetailService(
            dataRepository: dataRepository,
            cacheRepository: cacheRepository,
            apiRepository: apiRepository)
        let stockDetailViewModel = ZipStockDetailViewModel(service: stockDetailService, stock: stock)
        let stockDetailViewController = StockDetailViewController.instantiate(with: stockDetailViewModel)
        navigationController?.pushViewController(stockDetailViewController, animated: true)
    }
}

extension MainCoordinator: Coordinator {}
