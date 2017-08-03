//
//  WDCBConfiguration.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/1.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import Foundation
import CoreBluetooth

public class WDCBConfiguration {
    
    public let scanServiceUUIDs: [CBUUID]
    public let serviceUUID: CBUUID
    public let writeCharacteristicUUID: CBUUID
    public let notifyCharacteristicUUID: CBUUID
    
    public init(scanServiceUUIDs: [CBUUID], serviceUUID: CBUUID, writeCharacteristicUUID: CBUUID, notifyCharacteristicUUID: CBUUID) {
        self.scanServiceUUIDs = scanServiceUUIDs
        self.serviceUUID = serviceUUID
        self.writeCharacteristicUUID = writeCharacteristicUUID
        self.notifyCharacteristicUUID = notifyCharacteristicUUID
    }
    
}
