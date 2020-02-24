//
//  Error+Extensions.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

extension Error {
    func log() {
        NSLog(self.localizedDescription)
    }
}
