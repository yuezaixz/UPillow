//
//  BaseSettingCell.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/8.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit

class BaseSettingCell: UITableViewCell {
    
    static let identifier = "BaseSettingCell"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        textLabel?.textColor = Specs.color.tint
        textLabel?.font = Specs.font.large
        detailTextLabel?.font = Specs.font.large
        selectedBackgroundView = UIView(color: Specs.color.lightGray)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

