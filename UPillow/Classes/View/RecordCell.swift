//
//  RecordCell.swift
//  TodayMind
//
//  Created by 吴迪玮 on 2017/4/11.
//  Copyright © 2017年 cyan. All rights reserved.
//

import UIKit
import TMKit

class RecordCell: BaseCell {
    
    let button = UIButton()
    
    init(title: String, identifier: String, on: Bool) {
        super.init(style: .default, reuseIdentifier: identifier)
        textLabel?.text = title
        button.setTitle("long press", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 80, height: 40);
        button.isEnabled = false
        accessoryView = button
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
