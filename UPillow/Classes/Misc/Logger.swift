//
//  Logger.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/8.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import Foundation

public class Logger {
    
    static func debug(_ items: Any...) {
        #if DEBUG
            print("#debug: ", items)
        #endif
    }
    
    static func error(_ items: Any...) {
        print("#error: ", items)
    }
}
