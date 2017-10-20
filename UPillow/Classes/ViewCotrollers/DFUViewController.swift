/*
 * Copyright (c) 2016, Nordic Semiconductor
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import CoreBluetooth
import iOSDFULibrary

class DFUViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate {
    /// The UUID of the experimental Buttonless DFU Service from SDK 12.
    /// This service is not advertised so the app needs to connect to check if it's on the device's attribute list.
    static var dfuServiceUUID  = CBUUID(string: "00001530-1212-EFDE-1523-785FEABCD123")

    //MARK: - Class Properties
    var centralManager              : CBCentralManager?
    var dfuPeripheral          : CBPeripheral?
    var scanningStarted             : Bool = false
    var isOverOrTimeout             : Bool = false
    
    fileprivate var dfuController    : DFUServiceController?
    fileprivate var selectedFirmware : DFUFirmware?
    fileprivate var selectedFileURL  : URL?
    
    
    
    //MARK: - View Outlets
    @IBOutlet weak var dfuActivityIndicator  : UIActivityIndicatorView!
    @IBOutlet weak var dfuStatusLabel        : UILabel!
    @IBOutlet weak var peripheralNameLabel   : UILabel!
    @IBOutlet weak var dfuUploadProgressView : UIProgressView!
    @IBOutlet weak var dfuUploadStatus       : UILabel!
    @IBOutlet weak var stopProcessButton     : UIButton!
    
    //MARK: - View Actions
    
    @IBAction func actionBack(_ sender: Any) { self.navigationController?.popViewController(animated: true)
        if isOverOrTimeout {
            self.dismiss(animated: true, completion: {
                
            })
        } else {
            self.noticeError("升级中", autoClear: true, autoClearTime: 2)
        }
    }
    
    @IBAction func stopProcessButtonTapped(_ sender: AnyObject) {
        guard dfuController != nil else {
            print("No DFU peripheral was set")
            return
        }
        guard !dfuController!.aborted else {
            stopProcessButton.setTitle("Stop process", for: .normal)
            dfuController!.restart()
            return
        }
        
        print("Action: DFU paused")
        dfuController!.pause()
        let alertView = UIAlertController(title: "Warning", message: "Are you sure you want to stop the process?", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Abort", style: .destructive) {
            (action) in
            print("Action: DFU aborted")
            _ = self.dfuController!.abort()
        })
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel) {
            (action) in
            print("Action: DFU resumed")
            self.dfuController!.resume()
        })
        present(alertView, animated: true)
    }
    
    //MARK: - Class Implementation
    
    func startDiscovery() {
        if !scanningStarted {
            scanningStarted = true
            print("Start discovery")
            // the legacy and secure DFU UUIDs are advertised by devices in DFU mode,
            // the device info service is in the adv packet of DFU_HRM sample and the Experimental Buttonless DFU from SDK 12
            centralManager!.delegate = self
            centralManager!.scanForPeripherals(withServices: [
                DFUViewController.dfuServiceUUID])
            dfuStatusLabel.text = "搜索中..."
            performAfterDelay(sec: 15, handler: {
                if self.scanningStarted {
                    self.stopDiscovery()
                    self.noticeError("升级失败", autoClear: true, autoClearTime: 2)
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    func stopDiscovery() {
        if scanningStarted {
            print("stop discovery")
            scanningStarted = false
            centralManager!.stopScan()
        }
    }
    
    func getBundledFirmwareURLHelper() -> URL? {
        return Bundle.main.url(forResource: "ZT_S130_H801", withExtension: "zip")!
    }
    
    func startDFUProcess() {
        guard dfuPeripheral != nil else {
            print("No DFU peripheral was set")
            return
        }

        let dfuInitiator = DFUServiceInitiator(centralManager: centralManager!, target: dfuPeripheral!)
        dfuInitiator.delegate = self
        dfuInitiator.progressDelegate = self
        dfuInitiator.logger = self
        
        //不设置默认是12，没升级完成就会断开。
//        dfuInitiator.packetReceiptNotificationParameter = 1
        
        // This enables the experimental Buttonless DFU feature from SDK 12.
        // Please, read the field documentation before use.
        dfuInitiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
        
        dfuController = dfuInitiator.with(firmware: selectedFirmware!).start()
    }
    
    //MARK: - UIViewController implementation
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centralManager          = CBCentralManager(delegate: self, queue: nil) // The delegate must be set in init in order to work on iOS 8
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if centralManager!.state == .poweredOn {
            startDiscovery()
        }
    }
    
    func connectDfuPeripheral() {
        peripheralNameLabel.text = "升级中 \((dfuPeripheral?.name)!)..."
        dfuActivityIndicator.startAnimating()
        dfuUploadProgressView.progress = 0.0
        dfuUploadStatus.text = ""
        dfuStatusLabel.text  = ""
        stopProcessButton.isEnabled = false
        
        selectedFileURL  = getBundledFirmwareURLHelper()
        if selectedFileURL != nil {
            selectedFirmware = DFUFirmware(urlToZipFile: selectedFileURL!)
            startDFUProcess()
        } else {
            centralManager!.delegate = self
            centralManager!.connect(dfuPeripheral!)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _ = dfuController?.abort()
        dfuController = nil
    }

    //MARK: - CBCentralManagerDelegate API
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("CentralManager is now powered on")
            startDiscovery()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Ignore dupliactes.
        // They will not be reported in a single scan, as we scan without CBCentralManagerScanOptionAllowDuplicatesKey flag,
        // but after returning from DFU view another scan will be started.
        
        if advertisementData[CBAdvertisementDataServiceUUIDsKey] != nil {
            let name = peripheral.name ?? "Unknown"
            
            let legacyUUIDString = DFUViewController.dfuServiceUUID.uuidString
            let advertisedUUIDstring = ((advertisementData[CBAdvertisementDataServiceUUIDsKey]!) as AnyObject).firstObject as! CBUUID
            
            if advertisedUUIDstring.uuidString == legacyUUIDString {
                print("Found dfu Peripheral: \(name)")
                dfuPeripheral = peripheral
                connectDfuPeripheral()
                stopDiscovery()
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let name = peripheral.name ?? "Unknown"
        print("Connected to peripheral: \(name)")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let name = peripheral.name ?? "Unknown"
        print("Disconnected from peripheral: \(name)")
    }
    
    //MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        selectedFileURL  = getBundledFirmwareURLHelper()
        selectedFirmware = DFUFirmware(urlToZipFile: selectedFileURL!)
        startDFUProcess()
    }

    //MARK: - DFUServiceDelegate
    
    func dfuStateDidChange(to state: DFUState) {
        switch state {
        case .completed, .disconnecting:
            self.dfuActivityIndicator.stopAnimating()
            self.dfuUploadProgressView.setProgress(0, animated: true)
            self.stopProcessButton.isEnabled = false
            isOverOrTimeout = true
        case .aborted:
            self.dfuActivityIndicator.stopAnimating()
            self.dfuUploadProgressView.setProgress(0, animated: true)
            self.stopProcessButton.setTitle("Restart", for: .normal)
            self.stopProcessButton.isEnabled = true
        default:
            self.stopProcessButton.isEnabled = true
        }

        dfuStatusLabel.text = state.zhDescription()
        print("Changed state to: \(state.description())")
        
        // Forget the controller when DFU is done
        if state == .completed {
            dfuController = nil
        }
    }

    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        dfuStatusLabel.text = "错误 \(error.rawValue): \(message)"
        dfuActivityIndicator.stopAnimating()
        dfuUploadProgressView.setProgress(0, animated: true)
        print("Error \(error.rawValue): \(message)")
        
        // Forget the controller when DFU finished with an error
        dfuController = nil
    }
    
    //MARK: - DFUProgressDelegate
    
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        dfuUploadProgressView.setProgress(Float(progress)/100.0, animated: true)
        dfuUploadStatus.text = String(format: "进度: %d/%d\n速度: %.1f KB/s\n平均速度: %.1f KB/s",
                                      part, totalParts, currentSpeedBytesPerSecond/1024, avgSpeedBytesPerSecond/1024)
    }

    //MARK: - LoggerDelegate
    
    func logWith(_ level: LogLevel, message: String) {
        print("\(level.name()): \(message)")
    }
}

extension DFUState {
    public func zhDescription() -> String {
        switch self {
        case .connecting:      return "连接中"
        case .starting:        return "开始"
        case .enablingDfuMode: return "激活升级模式"
        case .uploading:       return "传输中"
        case .validating:      return "验证中"  // this state occurs only in Legacy DFU
        case .disconnecting:   return "断开中"
        case .completed:       return "已完成"
        case .aborted:         return "中止"
        }
    }
}
