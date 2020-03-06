//
//  Result.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 4/3/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

/*
 Used to represent the results of the API fetch data functions.
 */
enum Result<T, ResultError: Error> {
    case success(T)
    case failure(ResultError)
}
