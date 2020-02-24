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
    case network(Error)
    case decoding(Error)
    case server(URLResponse?)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL request."
        case .network(let error): return "Network: " + error.localizedDescription
        case .server(let response): return "Server " + (response.map { "response\($0)" } ?? "no repsonse")
        case .decoding(let error): return "Decoding: " + error.localizedDescription
        }
    }
}

enum DataError: Error {
    case context
    case fetch(Error)
    case save(Error)
}

extension DataError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .context: return "Cannot access Background Context."
        case .fetch(let error): return "Database fetch: \(error.localizedDescription)"
        case .save(let error): return "Database save: \(error.localizedDescription)"
        }
    }
}

enum ServiceError: Error {
    case stockSymbols
    case emptyStocks
    case deallocatedResources
}

extension ServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .stockSymbols: return "Error retrieving stock codes."
        case .emptyStocks:
            return """
                   Error retrieving stock information.
                   Please check your internet connection.
                   """
        case .deallocatedResources: return "Unable to fetch stocks due to deallocated resources."
        }
    }
}

enum ViewModelError: Error {
    case nilStock
}

extension ViewModelError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .nilStock: return "Favorite stock is nil."
        }
    }
}
