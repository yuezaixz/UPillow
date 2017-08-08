//
//  SwitchSettingCell.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/8.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit

class SwitchSettingCell: BaseSettingCell {
    
    let switcher = UISwitch()
    
    init(title: String, identifier: String, on: Bool) {
        super.init(style: .default, reuseIdentifier: identifier)
        textLabel?.text = title
        switcher.isOn = on
        accessoryView = switcher
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

