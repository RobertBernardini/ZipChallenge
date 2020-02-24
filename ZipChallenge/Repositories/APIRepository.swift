
//
//  APIRepository.swift
//  ZipCodeChallenge
//
//  Created by Robert Bernardini on 21/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire

enum Endpoint {
    case stockList
    case stockHistory(stock: String, startDate: Date, endDate: Date)
    case stockPriceList(stocks: [String])
    case stockProfileList(stocks: [String])
    
    var request: URLRequest? {
        guard let url = components.url else { return nil }
        guard var request = try? URLRequest(url: url, method: .get) else { return nil }
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    private static let basePath = "financialmodelingprep.com"
    
    private var path: String {
        switch self {
        case .stockList: return "/api/v3/company/stock/list"
        case .stockHistory(let stock, _, _): return "/api/v3/historical-price-full/\(stock)"
        case .stockPriceList(let stocks):
            let symbols = stocks.joined(separator: ",")
            return "/api/v3/stock/real-time-price/\(symbols)"
        case .stockProfileList(let stocks):
            let symbols = stocks.joined(separator: ",")
            return "/api/v3/company/profile/\(symbols)"
        }
    }
    
    private var queryItems: [URLQueryItem]? {
        switch self {
        case .stockHistory(_, let startDate, let endDate):
            let startDateQuery = URLQueryItem(name: "from", value: startDate.shortDatedString())
            let endDateQuery = URLQueryItem(name: "to", value: endDate.shortDatedString())
            return [startDateQuery, endDateQuery]
        case .stockList,
             .stockPriceList,
             .stockProfileList:
            return nil
        }
    }
    
    private var components: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Endpoint.basePath
        components.path = path
        components.queryItems = queryItems
        return components
    }
}

protocol APIRepository {
    func fetch<T: Decodable>(type: T.Type, at endpoint: Endpoint) -> Single<T>
}

class ZipAPIRepository: APIRepository {
    func fetch<T>(type: T.Type, at endpoint: Endpoint) -> Single<T> where T : Decodable {
        guard let request = endpoint.request else { return Single.error(APIError.invalidURL) }
        let manager = SessionManager.default
        return manager.rx.request(urlRequest: request)
            .validate(statusCode: 200..<300)
            .data()
            .map { try JSONDecoder().decode(T.self, from: $0) }
            .asSingle()
    }
}
