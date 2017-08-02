//
//  ViewController.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/7/31.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit
import CoreBluetooth

let kHomeStepCircleStartRed = 131.0/255.0
let kHomeStepCircleStartGreen =  50.0/255.0
let kHomeStepCircleStartBlue =  17.0/255.0
let kHomeStepCircleEndRed =  255.0/255.0
let kHomeStepCircleEndGreen =  183.0/255.0
let kHomeStepCircleEndBlue =  37.0/255.0

enum RMHomeStepCountStatus {
    case none
    case connecting
    case connected
}

class IndexViewController: UIViewController,WDCentralManageDelegate,WDPeriphealDelegate {
    
    @IBOutlet weak var autoConnectView: UIView!
    
    @IBOutlet var circleViews: [UIView]!
    
    private var animationTimer:Timer?
    
    private var status:RMHomeStepCountStatus = .none
    
    private var loadingIndex:Int = 0
    
    private var pillowConfiguration:WDCBConfiguration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.autoConnectView.layer.borderWidth = 1.0;
        self.autoConnectView.layer.borderColor = UIColor.lightGray.cgColor;
        WDCentralManage.shareInstance.delegate = self
        pillowConfiguration = WDCBConfiguration.init(
            scanServiceUUIDs: [CBUUID(nsuuid: UUID(uuidString: "00001801-0000-1000-8000-00805F9B34FB")!),
                               CBUUID(nsuuid:UUID(uuidString: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")!)],
            serviceUUID: CBUUID(nsuuid:UUID(uuidString: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")!),
            writeCharacteristicUUID: CBUUID(nsuuid:UUID(uuidString: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")!),
            notifyCharacteristicUUID: CBUUID(nsuuid:UUID(uuidString: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")!)
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.perform(#selector(scan), with: nil, afterDelay: 1)
//        self.perform(#selector(IndexViewController.autoConnect(uuidStr:)), with: "D0FAA379-9534-4CE9-9D28-B5BF1069D5B7", afterDelay: 1)
    }
    
//    @objc func autoConnect(uuidStr:String) {
//        startAnimation()
//        central.scanContinuouslyWithChangeHandler({ changes, discoveries in
//            for discovery in discoveries {
//                if discovery.remotePeripheral.identifier.uuidString == uuidStr {
//                    self.central.interruptScan()
//                    self.central.connect(remotePeripheral: discovery.remotePeripheral, completionHandler: { (bkPeripheal, error) in
//                        print("connected bkPeripheal:\(bkPeripheal)")
//                        bkPeripheal.delegate = self
//                        let data = "VN".data(using: String.Encoding.utf8)
//                        self.central.sendData(data!, toRemotePeer: bkPeripheal, completionHandler: { (data, bkPeer, error) in
//                            print("success send Data\(data),\(bkPeer)")
//                        })
//                    })
//                }
//            }
//        }, stateHandler: { newState in
//            if newState == .scanning {
//                print("scanning")
//            } else if newState == .stopped {
//                print("stopped")
//            }
//        }, errorHandler: { error in
//            print("Error from scanning: \(error)")
//        })
//    }
    
    @objc private func scan() {
        startAnimation()
        
        WDCentralManage.shareInstance.scanWithConfiguration(pillowConfiguration, duration: 10)
    }
    
    // MARK: circle animation
    
    func startAnimation() {
        loadingIndex = 0
        clearCircleColor()
        stopAnimation()
        animationTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(loadingAnimation), userInfo: nil, repeats: true);
//        animationTimer?.fire()
        self.status = .connecting
    }
    
    func stopAnimation() {
        if let currentTimer = animationTimer {
            currentTimer.invalidate()
        }
        animationTimer = nil
        status = .none
    }
    
    @objc func loadingAnimation() {
        loadingIndex = loadingIndex % 24
        clearCircleColor()
        changeCircleColor(startIndex: loadingIndex <= 12 ? -6 : (-6 + loadingIndex - 12), endIndex: loadingIndex <= 12 ? (-6 + loadingIndex) : 6)
        changeCircleColor(startIndex: loadingIndex <= 12 ? 6 : (6 + loadingIndex - 12), endIndex: loadingIndex <= 12 ? (6 + loadingIndex) : 18)
        loadingIndex += 1
    }
    
    func clearCircleColor() {
        for circleView in circleViews {
            circleView.backgroundColor = UIColor.init(red: 52.0/255.0, green: 47.0/255.0, blue: 59.0/255.0, alpha: 1.0);
        }
    }
    
    func changeCircleColor(startIndex:Int,endIndex:Int) {
        if startIndex == endIndex {
            return
        }
        for i in 0...(endIndex-startIndex) {
            var index = startIndex + i
            if index < 0 {
                index += 24
            }
            self.circleViews[index].backgroundColor = UIColor.init(
                red: CGFloat(kHomeStepCircleStartRed+(kHomeStepCircleEndRed-kHomeStepCircleStartRed)*Double(i/(endIndex-startIndex))),
                green: CGFloat(kHomeStepCircleStartGreen+(kHomeStepCircleEndGreen-kHomeStepCircleStartGreen)*Double(i/(endIndex-startIndex))),
                blue: CGFloat(kHomeStepCircleStartBlue+(kHomeStepCircleEndBlue-kHomeStepCircleStartBlue)*Double(i/(endIndex-startIndex))),
                alpha: 1.0
            )
        }
    }
    
    //MARK:WDCentralManageDelegate
    
    func discoverys(_ discoverys: [WDDiscovery]) {
        for discovery in discoverys {
            if discovery.remotePeripheral.identifier.uuidString == "B7ED2A72-3596-4857-B493-E592296EE266" {
                WDCentralManage.shareInstance.connect(discovery: discovery)
            }
        }
        print(discoverys)
    }
    
    func didConnected(for peripheal: WDPeripheal) {
        peripheal.delegate = self
    }
    
    //MARK:WDPeripheralDelegate
    
    func didFoundCharacteristic(_ peripheral: WDPeripheal) {
        peripheral.sendCommand("VN")
    }
    
    func wdPeripheral(_ peripheral: WDPeripheal, received receivedData: Data) {
        print(receivedData)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
