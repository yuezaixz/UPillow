//
//  ConnectViewController.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/4.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit

let kPillowSearchTimes =  30

class ConnectViewController: UIViewController,WDCentralManageDelegate,UITableViewDelegate,UITableViewDataSource,PillowDiscoveryCellDelegate,WDPeriphealDelegate {
    
    @IBOutlet weak var topShadowView: UIView!
    
    @IBOutlet weak var pillowSearchContainer: UIView!
    @IBOutlet weak var pillowSearchView: UIView!
    @IBOutlet weak var pillowSearchViewYellow: UIView!
    @IBOutlet weak var pillowSearchViewPurple: UIView!
    @IBOutlet weak var pillowStopSearchView: UIView!
    @IBOutlet weak var searchAgainLab: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var pillowSearchTableView: UITableView!
    
    @IBOutlet weak var currentPillowContainerView: UIView!
    @IBOutlet weak var pillowSearchStatusLab: UILabel!
    @IBOutlet weak var rssiLevelImageView: UIImageView!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var rssiDescriptorLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var connectLab: UILabel!
    @IBOutlet weak var connectedImageView: UIImageView!
    @IBOutlet weak var pillowFoundHeadView: UIView!
    @IBOutlet weak var disConnectBtn: UIButton!
    
    private var isSearch:Bool = false
    private let PillowDiscoveryCellIdentifier = "PillowDiscoveryCell"
    private var currentPeer:WDPeripheal?
    private var readRSSITimer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topShadowView.layer.shadowColor = UIColor.black.cgColor//shadowColor阴影颜色
        self.topShadowView.layer.shadowOffset = CGSize.init(width: 0.0, height: 0.8) //shadowOffset阴影偏移x，y向(上/下)偏移(-/+)2
        self.topShadowView.layer.shadowOpacity = 1.0//阴影透明度，默认0
        self.topShadowView.layer.shadowRadius = 5.0//阴影半径
        
        WDCentralManage.shareInstance.delegate = self
//        pillowSearchTableView.register(PillowDiscoveryCell.self, forCellReuseIdentifier: PillowDiscoveryCellIdentifier)
        pillowSearchTableView.dataSource = self
        pillowSearchTableView.delegate = self
        
        pillowSearchTableView.tableFooterView = UIView.init()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let currentPeer = WDCentralManage.shareInstance.currentPeer {
            self.currentPeer = currentPeer
            self.currentPeer?.delegate = self
            loadConnectedWDPeer(currentPeer)
            startReadRSSI()
        }
        self.perform(#selector(scan), with: nil, afterDelay: 0.2)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRSSITimer()
    }
    
    //MARK:Bluetooth
    @objc private func scan() {
        startSearchAnimation()
        WDCentralManage.shareInstance.scanWithConfiguration(WDCBConfigurationFactory.pillowConfiguration, duration: 30)
    }

    
    //MARK:Search Animations
    private func startSearchAnimation() {
        isSearch = true
        self.searchBtn.isUserInteractionEnabled = false
        self.pillowSearchView.isHidden = false
        self.pillowSearchViewYellow.isHidden = false
        self.pillowSearchViewPurple.isHidden = false
        self.pillowStopSearchView.isHidden = true
        self.pillowSearchView.layer.add(self.setAnimationWithDuration(3.5), forKey: "rotationAnimation")
        self.pillowSearchViewYellow.layer.add(self.setAnimationWithDuration(4.5), forKey: "rotationAnimation")
        self.pillowSearchViewPurple.layer.add(self.setAnimationWithDuration(5.0), forKey: "rotationAnimation")
    }
    
    private func interrupt() {
        isSearch = false
        self.searchBtn.isUserInteractionEnabled = true
        self.pillowSearchView.layer.removeAllAnimations()
        self.pillowSearchViewYellow.layer.removeAllAnimations()
        self.pillowSearchViewPurple.layer.removeAllAnimations()
        self.searchAgainLab.text = "点击重试"
        
        self.pillowSearchView.isHidden = true
        self.pillowSearchViewYellow.isHidden = true
        self.pillowSearchViewPurple.isHidden = true
        self.pillowStopSearchView.isHidden = false
        
        if WDCentralManage.shareInstance.bluetoothState == .poweredOff {
            self.noticeError("蓝牙开关未开启", autoClear: true, autoClearTime: 2)
        } else if let _ = WDCentralManage.shareInstance.currentPeer, WDCentralManage.shareInstance.discoveries.count > 0 {
            //TODO 未连接
        }
        self.searchAgainLab.text = "点击重试"
    }
    
    private func stopRSSITimer() {
        if let currentTimer = readRSSITimer {
            currentTimer.invalidate()
        }
        readRSSITimer = nil
    }
    
    private func startReadRSSI() {
        if let _ = self.currentPeer {
            stopRSSITimer()
            readRSSITimer = Timer.scheduledTimer(timeInterval: TimeInterval(2), target: self, selector: #selector(readRSSI), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func readRSSI() {
        if let currentPeer = self.currentPeer {
            currentPeer.startReadRSSI()
        }
    }
    
    func setAnimationWithDuration(_ duration:Double) -> CABasicAnimation {
        let rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = Double.pi * 2.0
        rotationAnimation.duration = CFTimeInterval(duration)
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float(kPillowSearchTimes)
        
        return rotationAnimation
    }
    
    private func loadConnectingDiscovery(_ discovery:WDDiscovery) {
        currentPillowContainerView.isHidden = false
        disConnectBtn.isEnabled = false
        connectLab.text = "连接中"
        deviceNameLabel.text = discovery.name
        self.rssiLabel.isHidden = true
        self.rssiDescriptorLabel.isHidden = true
    }
    
    private func loadConnectedWDPeer(_ peer:WDPeripheal) {
        currentPillowContainerView.isHidden = false
        disConnectBtn.isEnabled = true
        connectLab.text = "断开"
        deviceNameLabel.text = peer.name
        self.rssiLabel.isHidden = true
        self.rssiDescriptorLabel.isHidden = true
    }
    
    private func clearCurrentPeer() {
        self.currentPillowContainerView.isHidden = true
        
    }
    
    private func loadRSSI(_ rssi:Int) {
        if rssi < 0 {
            self.rssiLabel.isHidden = false
            self.rssiDescriptorLabel.isHidden = false
            if rssi > -30 {
                self.rssiLabel.text = "100%"
            }else{
                self.rssiLabel.text = "\(rssi + 130)%";
            }
            if rssi >= -70 {
                self.rssiLabel.textColor = Specs.color.insoleRSSILevelGreen
                self.rssiLevelImageView.image = UIImage.init(named: "icon_rssi_level_4")
            }else if rssi < -70 && rssi >= -80 {
                self.rssiLabel.textColor = Specs.color.insoleRSSILevelYellow
                self.rssiLevelImageView.image = UIImage.init(named: "icon_rssi_level_3")
            }else if rssi < -80 && rssi > -90 {
                self.rssiLabel.textColor = Specs.color.insoleRSSILevelYellow
                self.rssiLevelImageView.image = UIImage.init(named: "icon_rssi_level_2")
            }else{
                self.rssiLabel.textColor = Specs.color.insoleRSSILevelRed
                self.rssiLevelImageView.image = UIImage.init(named: "icon_rssi_level_1")
            }
        } else {
            self.rssiDescriptorLabel.isHidden = true
            self.rssiLabel.isHidden = true
        }
    }
    
    //MARK:UITableViewDelegate,UITableViewDatasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WDCentralManage.shareInstance.discoveries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PillowDiscoveryCell = pillowSearchTableView.dequeueReusableCell(withIdentifier: PillowDiscoveryCellIdentifier, for: indexPath) as! PillowDiscoveryCell
        let discovery = WDCentralManage.shareInstance.discoveries[indexPath.row]
        cell.loadByDevice(discovery,at: indexPath)
        cell.loadRSSI(discovery.RSSI)
        cell.delegate = self
        
        return cell
    }
    
    //MARK:Actions
    @IBAction func actionSearch(_ sender: UIButton) {
        startSearchAnimation()
        WDCentralManage.shareInstance.scanWithConfiguration(WDCBConfigurationFactory.pillowConfiguration, duration: 15)
    }
    
    @IBAction func actionDisconnectCurrent(_ sender: UIButton) {
        stopRSSITimer()
        WDCentralManage.shareInstance.disconnectCurrentPeer()
        self.clearCurrentPeer()
        startSearchAnimation()
        WDCentralManage.shareInstance.scanWithConfiguration(WDCBConfigurationFactory.pillowConfiguration, duration: 15)
    }
    
    //MARK:PillowDiscoveryCellDelegate
    func connectDiscovery(_ discovery:WDDiscovery, at indexPath:IndexPath){
        WDCentralManage.shareInstance.interruptScan()//停止搜索
        interrupt()//停止搜索的动画
        WDCentralManage.shareInstance.connect(discovery: discovery)
        self.loadConnectingDiscovery(discovery)
        
        self.pleaseWait(txt:"连接中")
        self.pillowSearchTableView.reloadData()
    }
    
    //MARK:WDCentralManageDelegate
    
    func scanTimeout() {
        interrupt()
    }
    
    func discoverys(_ discoverys: [WDDiscovery]) {
        if let lastPeerUUIDStr = WDCentralManage.shareInstance.lastPeerUUIDStr() {
            for discovery in discoverys {
                if discovery.remotePeripheral.identifier.uuidString == lastPeerUUIDStr {
                    WDCentralManage.shareInstance.connect(discovery: discovery)
                    self.pleaseWait(txt:"自动连接中")
                    break
                }
            }
        }
        pillowSearchTableView.reloadData()
    }
    
    func didConnected(for peripheal: WDPeripheal) {
        peripheal.delegate = self
        currentPeer = peripheal
        self.loadConnectedWDPeer(peripheal)
        self.clearAllNotice()
        self.noticeSuccess("连接成功", autoClear: true, autoClearTime: 2)
        self.pillowSearchTableView.reloadData()
    }
    
    func didDisConnected(for peripheal: WDPeripheal) {
        self.clearCurrentPeer()
        self.clearAllNotice()
        self.noticeError("断开连接", autoClear: true, autoClearTime: 2)
    }
    
    func failConnected(for uuidStr: String) {
        self.clearCurrentPeer()
        
        self.clearAllNotice()
        self.noticeError("连接失败", autoClear: true, autoClearTime: 2)
    }
    
    //MARK:WDPeripheralDelegate
    
    func didFoundCharacteristic(_ peripheral:WDPeripheal){
        startReadRSSI()
    }
    
    func wdPeripheral(_ peripheral:WDPeripheal, received receivedData:Data){
        
    }
    func wdPeripheral(_ peripheral:WDPeripheal, rssi:Int){
        self.loadRSSI(rssi)
    }
    
    //MARK:other
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
