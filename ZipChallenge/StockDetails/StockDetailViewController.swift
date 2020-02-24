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

final class StockDetailViewController: UIViewController {
    @IBOutlet var stockDetailView: StockDetailView!
    @IBOutlet var historicalPriceView: UIView!
    
    typealias ViewModel = StockDetailViewModel
    var viewModel: StockDetailViewModel!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUserInterface()
        bindUserInterface()
    }
    
    func configureUserInterface() {
        navigationItem.title = "Stock Details"

    }
    
    func bindUserInterface() {
        
    }
}

extension StockDetailViewController: ViewModelable {}
