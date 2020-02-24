//
//  UIApplication+Extensions.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 24/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    static var appVersion: String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return "Version \(appVersion) (\(build))"        
    }
    
    static func set(darkMode: Bool) {
        let interfaceStyle: UIUserInterfaceStyle = darkMode == true ? .dark : .light
        self.shared.windows.forEach({ $0.overrideUserInterfaceStyle = interfaceStyle })
    }
}
