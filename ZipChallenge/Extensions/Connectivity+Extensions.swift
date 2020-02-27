//
//  Connectivity+Extensions.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 27/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
    // Detects the connection to internet.
    static var isConnectedToInternet: Bool { NetworkReachabilityManager()?.isReachable ?? false }
}
