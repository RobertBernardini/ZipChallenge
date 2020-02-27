//
//  ViewDisplayable.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

/*
 Protocol to be conformed to by UI Views and their subclasses to allow
 easy setup of view displayable data.
 */
protocol ViewDisplayable {
    associatedtype DisplayData
    var displayData: DisplayData? { get set }
    
    func updateView()
}
