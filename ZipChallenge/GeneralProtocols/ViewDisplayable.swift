//
//  ViewDisplayable.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

protocol ViewDisplayable {
    associatedtype DisplayData
    var displayData: DisplayData? { get set }
    
    func updateView()
}
