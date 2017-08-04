//
//  WDCBConfigurationFactory.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/4.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import Foundation
import CoreBluetooth

class WDCBConfigurationFactory {
    public static let pillowConfiguration:WDCBConfiguration = WDCBConfiguration.init(
        scanServiceUUIDs: [CBUUID(nsuuid: UUID(uuidString: "00001801-0000-1000-8000-00805F9B34FB")!),
                           CBUUID(nsuuid:UUID(uuidString: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")!)],
        serviceUUID: CBUUID(nsuuid:UUID(uuidString: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")!),
        writeCharacteristicUUID: CBUUID(nsuuid:UUID(uuidString: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")!),
        notifyCharacteristicUUID: CBUUID(nsuuid:UUID(uuidString: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")!)
    )
}
