//
//  WDCentralManageState.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/4.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import Foundation
import CoreBluetooth

public enum WDCentralManagerState: ExpressibleByNilLiteral {
    case any
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
    
    public init(nilLiteral: Void) {
        self = .any
    }
    
    #if os(iOS) || os(tvOS)
    @available(iOS 10.0, tvOS 10.0, *)
    @available(OSX, unavailable)
    public init(managerState: CBManagerState) {
        switch managerState {
        case .poweredOn: self = .poweredOn
        case .poweredOff: self = .poweredOff
        case .resetting: self = .resetting
        case .unauthorized: self = .unauthorized
        case .unsupported: self = .unsupported
        default: self = nil
        }
    }
    #endif

    public init(centralManagerState: CBCentralManagerState) {
        switch centralManagerState {
        case .poweredOn: self = .poweredOn
        case .poweredOff: self = .poweredOff
        case .resetting: self = .resetting
        case .unauthorized: self = .unauthorized
        case .unsupported: self = .unsupported
        default: self = nil
        }
    }
}
