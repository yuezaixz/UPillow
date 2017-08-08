//
//  Bundle+Extensions.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/8.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import Foundation

extension Bundle {
    
    var name: String {
        guard let name = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String else { return "UPillow" }
        return name
    }
    
    var version: String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "1.0" }
        return version
    }
}
