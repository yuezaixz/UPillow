//
//  CBCentralManager+Extensions.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/4.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBCentralManager {
    
    internal var centralManagerState: CBCentralManagerState {
        get {
            return CBCentralManagerState(rawValue: state.rawValue) ?? .unknown
        }
    }
    
}
