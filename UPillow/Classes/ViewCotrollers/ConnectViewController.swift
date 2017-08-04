//
//  ConnectViewController.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/4.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit

let kPillowSearchTimes =  30

class ConnectViewController: UIViewController,WDCentralManageDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var topShadowView: UIView!
    
    @IBOutlet weak var pillowSearchContainer: UIView!
    @IBOutlet weak var pillowSearchView: UIView!
    @IBOutlet weak var pillowSearchViewYellow: UIView!
    @IBOutlet weak var pillowSearchViewPurple: UIView!
    @IBOutlet weak var pillowStopSearchView: UIView!
    @IBOutlet weak var searchAgainLab: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var pillowSearchTableView: UITableView!
    
    @IBOutlet weak var pillowSearchStatusLab: UILabel!
    @IBOutlet weak var rssiLevelImageView: UIImageView!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var connectLab: UILabel!
    @IBOutlet weak var connectedImageView: UIImageView!
    @IBOutlet weak var pillowFoundHeadView: UIView!
    
    private var isSearch:Bool = false
    private var searchTimer:Timer?
    private let PillowDiscoveryCellIdentifier = "PillowDiscoveryCell"
    
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
        self.perform(#selector(scan), with: nil, afterDelay: 0.2)
    }
    
    //MARK:Bluetooth
    @objc private func scan() {
        startSearchAnimation()
        WDCentralManage.shareInstance.scanWithConfiguration(WDCBConfigurationFactory.pillowConfiguration, duration: 15)
        
    }

    
    //MARK:Search Animations
    func startSearchAnimation() {
        isSearch = true
        self.searchBtn.isUserInteractionEnabled = false
        self.pillowSearchView.isHidden = false
        self.pillowSearchViewYellow.isHidden = false
        self.pillowSearchViewPurple.isHidden = false
        self.pillowStopSearchView.isHidden = true
        self.pillowSearchView.layer.add(self.setAnimationWithDuration(3.5), forKey: "rotationAnimation")
        self.pillowSearchViewYellow.layer.add(self.setAnimationWithDuration(4.5), forKey: "rotationAnimation")
        self.pillowSearchViewPurple.layer.add(self.setAnimationWithDuration(5.0), forKey: "rotationAnimation")
        
        searchTimer = Timer.scheduledTimer(timeInterval: TimeInterval(kPillowSearchTimes), target: self, selector: #selector(stopSearch), userInfo: nil, repeats: true);
        
    }
    
    @objc func stopSearch() {
        //TODO 停止搜索
        
        self.stopTimer()
    }
    
    func interrupt() {
        isSearch = false
        self.searchBtn.isUserInteractionEnabled = true
        self.pillowSearchView.layer.removeAllAnimations()
        self.pillowSearchViewYellow.layer.removeAllAnimations()
        self.pillowSearchViewPurple.layer.removeAllAnimations()
        self.stopTimer()
        self.searchAgainLab.text = "点击重试"
        
        self.pillowSearchView.isHidden = true
        self.pillowSearchViewYellow.isHidden = true
        self.pillowSearchViewPurple.isHidden = true
        self.pillowStopSearchView.isHidden = false
        
        if WDCentralManage.shareInstance.bluetoothState == .poweredOff {
            //TODO 未连接的提示
        } else if let _ = WDCentralManage.shareInstance.currentPeer, WDCentralManage.shareInstance.discoveries.count > 0 {
            //TODO 未连接
        }
        self.searchAgainLab.text = "点击重试"
    }
    
    func stopTimer() {
        if let currentTimer = searchTimer {
            currentTimer.invalidate()
        }
        searchTimer = nil
    }
    
    func setAnimationWithDuration(_ duration:Double) -> CABasicAnimation {
        let rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = Double.pi * 2.0
        rotationAnimation.duration = CFTimeInterval(duration)
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float(kPillowSearchTimes)
        
        return rotationAnimation
    }
    
    //MARK:UITableViewDelegate,UITableViewDatasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WDCentralManage.shareInstance.discoveries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PillowDiscoveryCell = pillowSearchTableView.dequeueReusableCell(withIdentifier: PillowDiscoveryCellIdentifier, for: indexPath) as! PillowDiscoveryCell
        let discovery = WDCentralManage.shareInstance.discoveries[indexPath.row]
        cell.loadByDevice(discovery)
        cell.loadRSSI(discovery.RSSI)
        
        return cell
    }
    
    //MARK:Actions
    @IBAction func actionSearch(_ sender: UIButton) {
        
    }
    
    @IBAction func actionDisconnectCurrent(_ sender: UIButton) {
        
    }
    
    //MARK:WDCentralManageDelegate
    
    func discoverys(_ discoverys: [WDDiscovery]) {
        //TODO 是否要自动连接下？
//        for discovery in discoverys {
//            if discovery.remotePeripheral.identifier.uuidString == "2B552FAC-F17E-4397-9E5F-D61B14B19FD5" {
//                WDCentralManage.shareInstance.connect(discovery: discovery)
//            }
//        }
        pillowSearchTableView.reloadData()
    }
    
    func didConnected(for peripheal: WDPeripheal) {
//        peripheal.delegate = self
        //TODO 展示连接上鞋垫后的界面及效果
    }
    
    func didDisConnected(for peripheal: WDPeripheal) {
        //TODO 掉线后自动连接等操作
    }
    
    func failConnected(for uuidStr: String) {
        
    }
    
    //MARK:other
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
