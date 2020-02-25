//
//  RefreshControl.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 25/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class RefreshHandler {
    let refresh = PublishSubject<Void>()
    let refreshControl = UIRefreshControl()
    
    init(view: UIScrollView) {
        view.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshControlDidRefresh(_: )), for: .valueChanged)
    }
    
    // MARK: - Action
    @objc func refreshControlDidRefresh(_ control: UIRefreshControl) {
        refresh.onNext(())
    }
    
    func end() {
        refreshControl.endRefreshing()
    }
}
