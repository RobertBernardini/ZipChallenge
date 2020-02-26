//
//  Errors.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case noInternet
    case decoding(Error)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL request."
        case .noInternet: return "There is no internet connection.\nSome features of this app may be limited. Saved stock data will shown."
        case .decoding(let error): return "Decoding Data: " + error.localizedDescription
        }
    }
}

enum DataError: Error {
    case fetch(Error)
    case save(Error)
}

extension DataError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fetch(let error): return "Database fetch: \(error.localizedDescription)"
        case .save(let error): return "Database save: \(error.localizedDescription)"
        }
    }
}
