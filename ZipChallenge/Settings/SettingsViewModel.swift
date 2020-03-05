//
//  SettingsViewModel.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/*
 View model that manages the requests of the Settings View Controller
 and returns the required data to be displayed. It uses Rx to bind
 signals and observers.
*/
protocol SettingsViewModelInputs {
    var setDarkMode: PublishRelay<Bool> { get }
}

protocol SettingsViewModelOutputs {
    var version: String { get }
    var isDarkMode: Bool { get }
}

protocol SettingsViewModelType {
    var inputs: SettingsViewModelInputs { get }
    var outputs: SettingsViewModelOutputs { get }
}

class SettingsViewModel {
    var inputs: SettingsViewModelInputs { self }
    var outputs: SettingsViewModelOutputs { self }
    
    // Inputs
    let setDarkMode = PublishRelay<Bool>()
    
    // Outputs
    var version: String { service.version }
    var isDarkMode: Bool { service.isDarkMode }
    
    private let service: SettingsServiceType
    private let bag = DisposeBag()

    init(service: SettingsServiceType) {
        self.service = service
        setDarkMode
            .subscribe(onNext: { service.set(darkMode: $0) })
            .disposed(by: bag)
    }
}

extension SettingsViewModel: SettingsViewModelType {}
extension SettingsViewModel: SettingsViewModelInputs {}
extension SettingsViewModel: SettingsViewModelOutputs {}
