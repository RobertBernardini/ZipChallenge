//
//  UIViewController+Extensions.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 25/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showPriceHistoryActionSheet(
        with title: String?,
        message: String?,
        handler: @escaping ((PriceChartDuration) -> Void)
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let options = PriceChartDuration.AllCases()
        options.forEach { option in
            let action = UIAlertAction(title: option.message, style: .default) { _ in
                handler(option)
            }
            alert.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
