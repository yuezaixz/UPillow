//
//  WDPeripheal.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/1.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import Foundation
import CoreBluetooth

public class WDDiscovery :Equatable {
    
    public var localName:String!
    
    public var name: String? {
        if let localName = self.localName {
            return localName
        }
        return advertisementData[CBAdvertisementDataLocalNameKey] as? String
    }
    
    /// The data advertised while the discovery was made.
    public let advertisementData: [String: Any]
    
    /// The remote peripheral that was discovered.
    public let remotePeripheral:CBPeripheral
    
    /// The [RSSI (Received signal strength indication)](https://en.wikipedia.org/wiki/Received_signal_strength_indication) value when the discovery was made.
    public var RSSI: Int
    
    // MARK: Initialization
    
    public init(advertisementData: [String: Any], remotePeripheral: CBPeripheral, RSSI: Int) {
        self.advertisementData = advertisementData
        self.remotePeripheral = remotePeripheral
        self.RSSI = RSSI
    }
    
    public static func ==(lhs: WDDiscovery, rhs: WDDiscovery) -> Bool {
        return lhs.remotePeripheral.identifier == rhs.remotePeripheral.identifier
    }
    
}
public protocol WDPeriphealDelegate: class {
    func didFoundCharacteristic(_ peripheral:WDPeripheal)
    func wdPeripheral(_ peripheral:WDPeripheal, received receivedData:Data)
}

public class WDPeripheal:NSObject,CBPeripheralDelegate {
    // MARK: Enums
    
    /**
     Possible states for WDPeripheal objects.
     - Shallow: The peripheral was initialized only with an identifier (used when one wants to connect to a peripheral for which the identifier is known in advance).
     - Disconnected: The peripheral is disconnected.
     - Connecting: The peripheral is currently connecting.
     - Connected: The peripheral is already connected.
     - Disconnecting: The peripheral is currently disconnecting.
     */
    public enum State {
        case shallow, disconnected, connecting, connected, disconnecting
    }
    
    // MARK: Properties
    
    /// The current state of the remote peripheral, either shallow or derived from an underlying CBPeripheral object.
    public var state: State {
//        if peripheral == nil {
//            return .shallow
//        }
        switch peripheral.state {
            case .disconnected: return .disconnected
            case .connecting: return .connecting
            case .connected: return .connected
            case .disconnecting: return .disconnecting
        }
    }
    
    /// The name of the remote peripheral, derived from an underlying CBPeripheral object.
    public var name: String? {
        return peripheral.name
    }
    
    public var maximumUpdateValueLength: Int {
        guard #available(iOS 9, *) else {
            return 20
        }
        return peripheral.maximumWriteValueLength(for: .withoutResponse)
    }
    public var identifier: UUID!
    public var configuration:WDCBConfiguration!
    public var peripheral: CBPeripheral!
    internal var writeCharacteristic:CBCharacteristic!
    internal var notifyCharacteristic:CBCharacteristic!
    
    public weak var delegate: WDPeriphealDelegate?
    
    // MARK: Initialization
    
    private override init() {
        super.init()
    }
    
    public convenience init(identifier: UUID, peripheral: CBPeripheral , configuration:WDCBConfiguration) {
        self.init()
        self.identifier = identifier
        self.peripheral = peripheral
        self.peripheral.delegate = self
        self.configuration = configuration
    }
    
    // MARK: Internal Functions
    
    internal func discoverServices() {
        if peripheral.services != nil {
            peripheral(peripheral, didDiscoverServices: nil)
            return
        }
        self.peripheral.discoverServices([self.configuration.serviceUUID])
    }
    
    internal func sendCommand(_ command:String) {
        if let data = command.data(using: String.Encoding.utf8) {
            self.peripheral.writeValue(data, for: writeCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
        }
    }
    
    internal func unsubscribe() {
        guard peripheral.services != nil else {
            return
        }
        for service in peripheral.services! {
            guard service.characteristics != nil else {
                continue
            }
            for characteristic in service.characteristics! {
                peripheral.setNotifyValue(false, for: characteristic)
            }
        }
    }
    
 public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            if service.uuid != configuration.serviceUUID {
                continue
            }
            if service.characteristics != nil {
                self.peripheral(peripheral, didDiscoverCharacteristicsFor: service, error: nil)
            } else {
                peripheral.discoverCharacteristics([configuration.writeCharacteristicUUID,configuration.notifyCharacteristicUUID], for: service)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard service.uuid == configuration.serviceUUID else {
            return
        }
        if let writeCharacteristic = service.characteristics?.filter({ $0.uuid == configuration.writeCharacteristicUUID }).last {
            self.writeCharacteristic = writeCharacteristic
        }
        if let notifyCharacteristic = service.characteristics?.filter({ $0.uuid == configuration.notifyCharacteristicUUID }).last {
            peripheral.setNotifyValue(true, for: notifyCharacteristic)
            self.notifyCharacteristic = notifyCharacteristic
        }
        if self.writeCharacteristic != nil && self.notifyCharacteristic != nil {
            self.delegate?.didFoundCharacteristic(self)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic.uuid == configuration.notifyCharacteristicUUID else {
            return
        }
        self.delegate?.wdPeripheral(self, received: characteristic.value!)
    }
}
