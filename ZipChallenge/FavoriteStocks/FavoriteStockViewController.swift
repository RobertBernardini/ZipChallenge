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
    enum Constants {
        static let favoriteStockCellIdentifier = "FavoriteStockCell"
    }
    
    @IBOutlet var tableView: UITableView!
    
    typealias ViewModel = FavoriteStockViewModel
    var viewModel: FavoriteStockViewModel!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUserInterface()
        bindUserInterface()
    }

    
    func configureUserInterface() {
        navigationItem.title = "Favourite Stocks"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
//        tableView.dataSource = self
        tableView.register(StockTableViewCell.self, forCellReuseIdentifier: Constants.favoriteStockCellIdentifier)
    }
    
    func bindUserInterface() {

    }

}

extension FavoriteStockViewController: ViewModelable {}
