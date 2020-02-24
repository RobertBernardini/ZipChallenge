//
//  StockProfileList.swift
//  ZipCodeChallenge
//
//  Created by Robert Bernardini on 21/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation

struct StockProfileList  {
    struct StockProfile {
        struct StockProfileData {
            let price: Decimal
            let beta: String
            let volAvg: String
            let mktCap: String
            let lastDiv: String
            let range: String
            let changes: Decimal
            let changesPercentage: String
            let companyName: String
            let exchange: String
            let industry: String
            let website: String
            let companyDescription: String
            let ceo: String
            let sector: String
            let image: String
        }
        
        let symbol: String
        let data: StockProfileData
    }

    let profiles: [StockProfile]
}

extension StockProfileList: Decodable {
    enum CodingKeys: String, CodingKey {
        case profiles = "companyProfiles"
    }
}

extension StockProfileList.StockProfile: Decodable {
    enum CodingKeys: String, CodingKey {
        case symbol
        case data = "profile"
    }
}

extension StockProfileList.StockProfile.StockProfileData: Decodable {
    enum CodingKeys: String, CodingKey {
        case price
        case beta
        case volAvg
        case mktCap
        case lastDiv
        case range
        case changes
        case changesPercentage
        case companyName
        case exchange
        case industry
        case website
        case companyDescription = "description"
        case ceo
        case sector
        case image
    }
}
