//
//  ViewController.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/7/31.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit

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

class IndexViewController: UIViewController,WDCentralManageDelegate,WDPeriphealDelegate,PDataHandleDelegate {
    
    @IBOutlet weak var autoConnectView: UIView!
    @IBOutlet weak var buyInfoContainerView: UIView!
    private var _redShadeButton : PRedShadeButton!
    
    @IBOutlet weak var demoImageView: UIImageView!
    
    @IBOutlet var circleViews: [UIView]!
    
    @IBOutlet weak var topDataContainerView: UIView!
    @IBOutlet weak var sleepPoseLabel: UILabel!
    @IBOutlet weak var pillowLevelLabel: UILabel!
    
    
    private var animationTimer:Timer?
    
    private var status:RMHomeStepCountStatus = .none
    
    private var loadingIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.autoConnectView.layer.borderWidth = 1.0;
        self.autoConnectView.layer.borderColor = UIColor.lightGray.cgColor;
        
        //由于Xcode9 beta5的bug，所以通过代码添加gesture
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(tapConnectGestureAction(_:)))
        gesture.numberOfTapsRequired = 1
        
        self.autoConnectView.addGestureRecognizer(gesture)
        
        WDCentralManage.shareInstance.delegate = self
        PDataHandle.shareInstance.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //头部购买按钮初始化
        _redShadeButton = PRedShadeButton.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.buyInfoContainerView.bounds.size.height), text: "购买枕头")
        _redShadeButton.addTarget(self, action: #selector(actionBuy), for: .touchUpInside)

        self.buyInfoContainerView.addSubview(_redShadeButton)

        if let currentPeer = WDCentralManage.shareInstance.currentPeer {
            self.loadCurrentPeer(currentPeer)
            self.buyInfoContainerView.isHidden = true
        } else if let _ = WDCentralManage.shareInstance.lastPeerUUIDStr(){
            self.buyInfoContainerView.isHidden = true
            autoConnectView.isHidden = false
            self.perform(#selector(autoConnect), with: nil, afterDelay: 0.5)
            self.pleaseWait(txt: "自动连接中")
        } else {
            self.buyInfoContainerView.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.status == .connecting {//离开的时候，如果还在连接，都停止搜索并把动画给停了
            WDCentralManage.shareInstance.interruptScan()
            loadingIndex = 0
            clearCircleColor()
            stopAnimation()
        }
    }
    
    @objc func autoConnect() {
        if let lastConnectUUIDStr = WDCentralManage.shareInstance.lastPeerUUIDStr() {
            startAnimation()
            WDCentralManage.shareInstance.autoConnect(with: WDCBConfigurationFactory.pillowConfiguration, for: lastConnectUUIDStr, duration:15)
        }
    }
    
    func loadCurrentPeer(_ peer:WDPeripheal) {
        autoConnectView.isHidden = true
        //TODO 加载当前连接的鞋垫
        demoImageView.isHidden = false
        topDataContainerView.isHidden = false
        loadNextImage(1)
    }
    
    func loadNextImage(_ i:Int) {
//        demoImageView.image = UIImage.init(named: "icon_demo_side_\(i)")
//        var nextIndex = i + 1
//        if nextIndex > 10 {
//            nextIndex = 1
//        }
//        performAfterDelay(sec: 0.1) {
//            self.loadNextImage(nextIndex)
//        }
    }
    
    // MARK: circle animation
    
    func startAnimation() {
        loadingIndex = 0
        clearCircleColor()
        stopAnimation()
        animationTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(loadingAnimation), userInfo: nil, repeats: true);
        self.status = .connecting
    }
    
    func stopAnimation() {
        if let currentTimer = animationTimer {
            currentTimer.invalidate()
        }
        animationTimer = nil
        status = .none
        clearCircleColor()
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
    
    //MARK: Action
    
    @IBAction func tapConnectGestureAction(_ sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.ended {
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let connectViewController = sb.instantiateViewController(withIdentifier: "ConnectViewController") as! ConnectViewController
            self.present(connectViewController, animated: true, completion: nil)
            
        }
    }
    @objc private func actionBuy() {
        guard let url = URL(string: "http://www.podoon.com") else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:])
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    //MARK:WDCentralManageDelegate
    
    func didConnected(for peripheal: WDPeripheal) {
        peripheal.delegate = self
        stopAnimation()
        self.clearAllNotice()
        self.loadCurrentPeer(peripheal)
        self.noticeSuccess("连接成功", autoClear: true, autoClearTime: 2)
    }
    
    func didDisConnected(for peripheal: WDPeripheal) {
        self.clearAllNotice()
        self.noticeError("断开连接", autoClear: true, autoClearTime: 2)
    }
    
    func failConnected(for uuidStr: String) {
        stopAnimation()
        self.clearAllNotice()
        self.noticeError("连接失败", autoClear: true, autoClearTime: 2)
    }
    
    func autoConnectTimeout(for uuidStr: String) {
        stopAnimation()
    }
    
    //MARK:WDPeripheralDelegate
    
    func didFoundCharacteristic(_ peripheral: WDPeripheal) {
        peripheral.sendCommand("VN")
    }
    
    func wdPeripheral(_ peripheral: WDPeripheal, received receivedData: Data) {
        PDataHandle.shareInstance.handleReceivedData(receivedData)
    }
    
    //MARK:PDataHandleDelegate
    
    func notifyPillow(majorVersion: Int, minorVersion: Int, reVersion: Int) {
        print("Pillow Version:\(majorVersion).\(minorVersion).\(reVersion)")
    }
    
    //MARK:other

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
