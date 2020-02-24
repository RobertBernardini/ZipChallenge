//
//  SettingsDarkModeTableViewCell.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import UIKit

protocol SettingsDarkModeTableViewCellDelegate: AnyObject {
    func settingsDarkModeTableViewCell(_ cell: SettingsDarkModeTableViewCell, didUpdateDarkMode isDarkMode: Bool)
}

class SettingsDarkModeTableViewCell: UITableViewCell {
    @IBOutlet var darkModeSwitch: UISwitch!
    
    weak var delegate: SettingsDarkModeTableViewCellDelegate?
    
    var isDarkMode: Bool = false {
        didSet {
            darkModeSwitch.setOn(isDarkMode, animated: false)
        }
    }
        
    @IBAction func didTapSwitch(_ sender: UISwitch) {
        self.delegate?.settingsDarkModeTableViewCell(self, didUpdateDarkMode: sender.isOn)
    }
}
