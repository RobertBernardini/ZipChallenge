//
//  DataRepositoryTests.swift
//  ZipChallengeTests
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import XCTest
import RxSwift
@testable import ZipChallenge

class DataRepositoryTests: XCTestCase {
    private let dataRepository: DataRepository
    
    override func setUp() {
        dataRepository = ZipDataRepository()
    }

    override func tearDown() {
        
    }

    func testExample() {
        
    }
}
