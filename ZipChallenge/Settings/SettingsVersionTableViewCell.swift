//
//  SettingsVersionTableViewCell.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import UIKit

class SettingsVersionTableViewCell: UITableViewCell {
    @IBOutlet var versionLabel: UILabel!

    var version: String? {
        didSet { updateView() }
    }
    
    func updateView() {
        guard let version = version else { return }
        versionLabel.text = version
    }
}
