//
//  WDCentralManage.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/1.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import Foundation
import CoreBluetooth

let kLastPillowKey =  "kLastPillowKey"
let kLastPillowName =  "kLastPillowName"
let kLastPillowUUID =  "kLastPillowUUID"
let kLastPillowUserId =  "kLastPillowUserId"

/**
 The central's delegate is called when asynchronous events occur.
 */
public protocol WDCentralManageDelegate: class {
    
    func discoverys(_ discoverys:[WDDiscovery])
    func didConnected(for peripheal:WDPeripheal)
    func didDisConnected(for peripheal:WDPeripheal)
    func failConnected(for uuidStr:String)
    func autoConnectTimeout(for uuidStr:String)
    func scanTimeout()
    func changeState(_ state:WDCentralManagerState)
}

//空实现，optional
extension WDCentralManageDelegate {
    func discoverys(_ discoverys:[WDDiscovery]){
        
    }
    func didConnected(for peripheal:WDPeripheal){
        
    }
    func didDisConnected(for peripheal:WDPeripheal){
        
    }
    func failConnected(for uuidStr:String){
        
    }
    func autoConnectTimeout(for uuidStr:String){
        
    }
    func scanTimeout(){
        
    }
    func changeState(_ state:WDCentralManagerState){
        
    }
}

public class WDCentralManage: NSObject,CBCentralManagerDelegate {
    
    static let shareInstance: WDCentralManage = WDCentralManage()
    
    private var _centralManager: CBCentralManager!
    
    private var _currentConfiguration: WDCBConfiguration!
    
    private var _durationTimer: Timer!
    
    private var busy: Bool = false
    
    public var discoveries:[WDDiscovery] = []
    
    public var currentPeer:WDPeripheal!
    
    public weak var delegate: WDCentralManageDelegate?
    
    public var _connectingUUIDStr : String?
    
    public var _autoConnectUUIDStr : String?
    
    var bluetoothState:WDCentralManagerState {
        guard let _ = _centralManager else {
            return WDCentralManagerState.unsupported
        }
        if #available(tvOS 10.0, iOS 10.0, *) {
            return WDCentralManagerState(managerState: _centralManager.state)
        } else {
            return WDCentralManagerState(centralManagerState: _centralManager.centralManagerState)
        }
    }
    
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
        
        if self.bluetoothState == .poweredOn {
            scan(duration: duration)
        } else {
            self.perform(#selector(scan(duration:)), with: duration, afterDelay: 1)
        }
        
    }
    
    @objc internal func scan(duration:Int) {
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
        if let autoConnectUUIDStr = _autoConnectUUIDStr {
            delegate?.autoConnectTimeout(for: autoConnectUUIDStr)
        } else {
            delegate?.scanTimeout()
        }
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
    
    private func saveLastUUIDStr(_ uuidStr:String, name:String, userId:Int) {
        UserDefaults.standard.set([kLastPillowUUID:uuidStr, kLastPillowName:name, kLastPillowUserId:userId], forKey: kLastPillowKey)
    }
    
    private func clearLastUUIDStr() {
        UserDefaults.standard.removeObject(forKey: kLastPillowKey)
    }
    
    func lastPeerUUIDStr() -> String? {
        guard let dict = UserDefaults.standard.object(forKey: kLastPillowKey) as? Dictionary<String, Any> else {
            return nil
        }
        return dict[kLastPillowUUID] as? String
    }
    
    func lastPeerName() -> String? {
        guard let dict = UserDefaults.standard.object(forKey: kLastPillowKey) as? Dictionary<String, Any> else {
            return nil
        }
        return dict[kLastPillowName] as? String
    }
    
    func disconnectCurrentPeer(){
        guard let centralManager = _centralManager else {
            return
        }
        
        if let currentPeer = self.currentPeer {
            centralManager.cancelPeripheralConnection(currentPeer.peripheral)
            self.currentPeer = nil
            clearLastUUIDStr()
        }
    }
    
    func connect(discovery:WDDiscovery) {
        if let _ = _connectingUUIDStr {
            return
        }
        guard let centralManager = _centralManager else {
            return
        }
        
        if let currentPeer = self.currentPeer {
            if currentPeer.identifier == discovery.remotePeripheral.identifier {
                //同一个，不重复连接了
                return
            } else {
                centralManager.cancelPeripheralConnection(discovery.remotePeripheral)
                self.currentPeer = nil
            }
        }
        saveLastUUIDStr(discovery.remotePeripheral.identifier.uuidString, name: discovery.remotePeripheral.name ?? "", userId: 0)
        print("connect \(discovery.remotePeripheral.identifier)")
        _connectingUUIDStr = discovery.remotePeripheral.identifier.uuidString
        centralManager.connect(discovery.remotePeripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey:true])
    }
    
    func autoConnect(with configuration:WDCBConfiguration, for uuidStr:String, duration:Int) {
        _autoConnectUUIDStr = uuidStr
        self.scanWithConfiguration(configuration, duration: duration)
    }
    
    // MARK: CBCentralManagerDelegate
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //通过delegate通知状态变化
        if #available(tvOS 10.0, iOS 10.0, *) {
            delegate?.changeState(WDCentralManagerState(managerState: _centralManager.state))
        } else {
            delegate?.changeState(WDCentralManagerState(centralManagerState: _centralManager.centralManagerState))
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let discovery = WDDiscovery.init(advertisementData: advertisementData, remotePeripheral: peripheral, RSSI: RSSI.intValue)
        if let autoConnectUUIDStr = _autoConnectUUIDStr {
            if discovery.remotePeripheral.identifier.uuidString == autoConnectUUIDStr {
                self.interruptScan()
                _autoConnectUUIDStr = nil
                self.connect(discovery: discovery)
            }
        } else {
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
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        _connectingUUIDStr = nil
        currentPeer = WDPeripheal.init(identifier: peripheral.identifier, peripheral: peripheral, configuration: _currentConfiguration)
        delegate?.didConnected(for: currentPeer)
        currentPeer.discoverServices()
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let currentPeer = self.currentPeer,currentPeer.identifier == peripheral.identifier {
            delegate?.didDisConnected(for: currentPeer)
            self.currentPeer = nil
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate?.failConnected(for: _connectingUUIDStr ?? peripheral.identifier.uuidString)
        _connectingUUIDStr = nil
    }
    
}
