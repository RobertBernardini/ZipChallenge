//
//  SettingsService.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 21/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import UIKit

/*
 Service that obtains the data requested by the Settings View Model.
 It has a variable for access to the version.
 It has a variable for access to the dark mode value.
 It sets the dark mode.
*/
protocol SettingsService {
    var version: String { get }
    var isDarkMode: Bool { get }
    
    func set(darkMode: Bool)
}

enum SettingsConstant {
    static let darkMode = "darkMode"
}

class ZipSettingsService {
    var version: String { UIApplication.appVersion }
    var isDarkMode: Bool { UserDefaults.standard.bool(forKey: SettingsConstant.darkMode) }
    
    init() {}
}

extension ZipSettingsService: SettingsService {
    func set(darkMode: Bool) {
        // To remember the setting when the app is relaunched the value is saved in
        // User defaults.
        UserDefaults.standard.set(darkMode, forKey: SettingsConstant.darkMode)
        UIApplication.set(darkMode: darkMode)
    }
}
