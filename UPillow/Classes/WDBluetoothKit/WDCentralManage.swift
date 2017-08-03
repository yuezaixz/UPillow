//
//  WDCentralManage.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/1.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import Foundation
import CoreBluetooth

/**
 The central's delegate is called when asynchronous events occur.
 */
public protocol WDCentralManageDelegate: class {
    
    func discoverys(_ discoverys:[WDDiscovery])
    func didConnected(for peripheal:WDPeripheal)
    func didDisConnected(for peripheal:WDPeripheal)
    func failConnected(for uuidStr:String)
}

public class WDCentralManage: NSObject,CBCentralManagerDelegate {
    
    static let shareInstance: WDCentralManage = WDCentralManage()
    
    private var _centralManager: CBCentralManager!
    
    private var _currentConfiguration: WDCBConfiguration!
    
    private var _durationTimer: Timer!
    
    private var busy: Bool = false
    
    private var discoveries:[WDDiscovery] = []
    
    public var currentPeer:WDPeripheal!
    
    public weak var delegate: WDCentralManageDelegate?
    
    public var _connectingUUIDStr : String?
    
    public enum ContinuousScanState {
        case stopped
        case scanning
        case waiting
    }
    
    // MARK: Initialization
    
    override init() {
        super.init()
        _centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    // MARK: API
    func scanWithConfiguration(_ configuration:WDCBConfiguration, duration:Int) {
        busy = true
        _currentConfiguration = configuration
        if let centralManager = _centralManager {
            centralManager.scanForPeripherals(withServices: _currentConfiguration.scanServiceUUIDs, options: nil)
            invalidateTimer()
            _durationTimer = Timer.scheduledTimer(timeInterval: TimeInterval(duration), target: self, selector: #selector(WDCentralManage.durationTimerElapsed), userInfo: nil, repeats: false)
            
        }
    }
    
    internal func interruptScan() {
        guard busy else {
            return
        }
        endScan()
    }
    
    @objc private func durationTimerElapsed() {
        endScan()
    }
    
    private func endScan() {
        invalidateTimer()
        if let centralManager = _centralManager {
            centralManager.stopScan()
        }
        self.discoveries.removeAll()
        busy = false
    }
    
    func invalidateTimer() {
        if let durationTimer = _durationTimer {
            durationTimer.invalidate()
            _durationTimer = nil
        }
    }
    
    func connect(discovery:WDDiscovery) {
        if let _ = _connectingUUIDStr {
            return
        }
        if let centralManager = _centralManager {
            print("connect \(discovery.remotePeripheral.identifier)")
            _connectingUUIDStr = discovery.remotePeripheral.identifier.uuidString
            centralManager.connect(discovery.remotePeripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey:true])
        }
    }
    
    // MARK: CBCentralManagerDelegate
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //通过delegate通知状态变化
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let discovery = WDDiscovery.init(advertisementData: advertisementData, remotePeripheral: peripheral, RSSI: RSSI.intValue)
        if !discoveries.contains(discovery) {
            discoveries.append(discovery)
        } else {
            if let resultDiscovery = discoveries.filter({ (foundPeripheral) -> Bool in
                foundPeripheral == discovery
            }).last {
                resultDiscovery.RSSI = RSSI.intValue
            }
        }
        
        delegate?.discoverys(discoveries)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        _connectingUUIDStr = nil
        currentPeer = WDPeripheal.init(identifier: peripheral.identifier, peripheral: peripheral, configuration: _currentConfiguration)
        delegate?.didConnected(for: currentPeer)
        currentPeer.discoverServices()
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        delegate?.didDisConnected(for: currentPeer)
        currentPeer = nil
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate?.failConnected(for: _connectingUUIDStr ?? peripheral.identifier.uuidString)
        _connectingUUIDStr = nil
    }
    
}
