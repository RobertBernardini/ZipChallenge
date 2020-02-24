//
//  SettingsViewModel.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

protocol SettingsViewModel {
    var version: String { get }
    var isDarkMode: Bool { get }
    
    func set(darkMode: Bool)
}

class ZipSettingsViewModel {
    private let service: SettingsService
    var version: String { service.version }
    var isDarkMode: Bool { service.isDarkMode }

    init(service: SettingsService) {
        self.service = service
    }
}

extension ZipSettingsViewModel: SettingsViewModel {
    func set(darkMode: Bool) {
        service.set(darkMode: darkMode)
    }
}
