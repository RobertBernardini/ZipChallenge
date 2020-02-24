
//
//  ViewModelable.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import UIKit

protocol ViewModelable {
    associatedtype ViewModel
    var viewModel: ViewModel! { get set }
    
    static func instantiate(with viewModel: ViewModel) -> Self
    func configureUserInterface()
    func bindUserInterface()
}

extension ViewModelable {
    func bindUserInterface() {}
    
    static func instantiate(with viewModel: ViewModel) -> Self {
        //        let fullName = NSStringFromClass(self)
        //        let className = fullName.components(separatedBy: ".")[1]
        let className = String(describing: self)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard var viewController = storyboard.instantiateViewController(withIdentifier: className) as? Self else {
            fatalError("Unable to instantiate VC named \(className)")
        }
        viewController.viewModel = viewModel
        return viewController
    }
}
