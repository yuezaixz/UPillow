//
//  PillowDiscoveryCell.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/4.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit

public class PillowDiscoveryCell :UITableViewCell {
    
    @IBOutlet weak var rssiLab: UILabel!
    @IBOutlet weak var rssiLevelImageView: UIImageView!
    @IBOutlet weak var deviceNameLab: UILabel!
    @IBOutlet weak var connectLab: UILabel!
    @IBOutlet weak var rssiDescriperLab: UILabel!
    
    private var isConnected_:Bool = false
    
//    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.connectLab.layer.borderColor = UIColor.lightGray.cgColor
//    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    public override func awakeFromNib() {
//        self.connectLab.layer.borderColor = UIColor.lightGray.cgColor
//    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
    }
    
    func loadByDevice(_ device:WDDiscovery) {
        self.connectLab.layer.borderColor = UIColor.lightGray.cgColor
        self.rssiLab.isHidden = true
        self.rssiDescriperLab.isHidden = true
        
        self.loadRSSI(device.RSSI)
        
        self.deviceNameLab.text = device.name
        
        
    }
    
    func loadRSSI(_ rssi:Int) {
        if rssi < 0 {
            self.rssiLab.isHidden = false
            self.rssiDescriperLab.isHidden = false
            if rssi > -30 {
                self.rssiLab.text = "100%"
            }else{
                self.rssiLab.text = "\(rssi + 130)%";
            }
            if rssi >= -70 {
                self.rssiLab.textColor = Colors.InsoleRssiLevelGreen()
                self.rssiLevelImageView.image = UIImage.init(named: "icon_rssi_level_4")
            }else if rssi < -70 && rssi >= -80 {
                self.rssiLab.textColor = Colors.InsoleRssiLevelYellow()
                self.rssiLevelImageView.image = UIImage.init(named: "icon_rssi_level_3")
            }else if rssi < -80 && rssi > -90 {
                self.rssiLab.textColor = Colors.InsoleRssiLevelYellow()
                self.rssiLevelImageView.image = UIImage.init(named: "icon_rssi_level_2")
            }else{
                self.rssiLab.textColor = Colors.InsoleRssiLevelRed()
                self.rssiLevelImageView.image = UIImage.init(named: "icon_rssi_level_1")
            }
        } else {
            self.rssiLab.isHidden = true
            self.rssiDescriperLab.isHidden = true
        }
    }
    
}
