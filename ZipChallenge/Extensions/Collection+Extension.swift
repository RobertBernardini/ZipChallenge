
//
//  Collection+Extension.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 26/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

extension Collection where Element: Equatable {
    func indexes(of element: Element) -> [Int] {
        return self.enumerated().filter({ element == $0.element }).map({ $0.offset })
    }
}
