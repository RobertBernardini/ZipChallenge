//
//  Coordinator.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator {
    var tabBarController: UITabBarController { get }
    
    func start()
}

class MainCoordinator {
    var tabBarController: UITabBarController
    private var stocks: [StockModel] = []
    private let dataRepository: DataRepository
    private let apiRepository: APIRepository
    
    init(
        tabBarController: UITabBarController,
        dataRepository: DataRepository = ZipDataRepository(),
        apiRepository: APIRepository = ZipAPIRepository()
    ) {
        self.tabBarController = tabBarController
        self.dataRepository = dataRepository
        self.apiRepository = apiRepository
    }
    
    func start() {
        let stockService: StockService = ZipStockService(dataRepository: dataRepository, apiRepository: apiRepository)
        let stockViewModel: StockViewModel = ZipStockViewModel(service: stockService)
        let stockViewController = StockViewController.instantiate(with: stockViewModel)
        let stockImage = UIImage(named: "stock")
        stockViewController.tabBarItem = UITabBarItem(title: "Stocks", image: stockImage, tag: 0)

        let favoriteStockService: FavoriteStockService = ZipFavoriteStockService(dataRepository: dataRepository, apiRepository: apiRepository)
        let favoriteStockViewModel = ZipFavoriteStockViewModel(service: favoriteStockService)
        let favoriteStockViewController = FavoriteStockViewController.instantiate(with: favoriteStockViewModel)
        favoriteStockViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        
        let settingsService: SettingsService = ZipSettingsService()
        let settingsViewModel = ZipSettingsViewModel(service: settingsService)
        let settingsViewController = SettingsViewController.instantiate(with: settingsViewModel)
        let settingsImage = UIImage(named: "settings")
        settingsViewController.tabBarItem = UITabBarItem(title: "Stocks", image: settingsImage, tag: 2)
        
        let controllers = [stockViewController, favoriteStockViewController, settingsViewController]
        tabBarController.viewControllers = controllers.map({ UINavigationController(rootViewController: $0) })
    }
    
    func showStockDetails(for stock: StockModel) {
        let stockDetailService: StockDetailService = ZipStockDetailService(dataRepository: dataRepository, apiRepository: apiRepository)
        let stockDetailViewModel = ZipStockDetailViewModel(service: stockDetailService, stock: stock)
        let stockDetailViewController = StockDetailViewController.instantiate(with: stockDetailViewModel)
        
    }
}

extension MainCoordinator: Coordinator {}
