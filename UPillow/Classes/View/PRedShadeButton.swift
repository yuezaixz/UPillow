//
//  PRedShadeButton.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/8.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit

class PRedShadeButton: UIView {
    
    var redShadeButton:UIButton = {
        var button:UIButton = UIButton.init()
        return button
    }()
    
    private var _gradientLayer:CAGradientLayer!
    
    init(frame: CGRect ,text: String) {
        super.init(frame: frame)
        setUpWithTitle(text, frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadButtonTitle(_ title:String, frame:CGRect) {
        redShadeButton.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        redShadeButton.setTitle(title, for: .normal)
        self.redShadeButton.contentHorizontalAlignment = .center
        self.addSubview(self.redShadeButton)
        self.bringSubview(toFront: self.redShadeButton)
    }
    
    func setUpWithTitle(_ title:String, frame:CGRect) {
        _gradientLayer = CAGradientLayer.init()
        _gradientLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        _gradientLayer.colors = [UIColor.init(red: 190.0/255.0, green: 44.0/255.0, blue: 25.0/255.0, alpha: 1.0).cgColor,
                                UIColor.init(red: 211.0/255.0, green:85.0/255.0, blue:13.0/255.0, alpha: 1.0).cgColor]
        _gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        _gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        self.layer.addSublayer(_gradientLayer)
        loadButtonTitle(title, frame: frame)
    }
    
    func addTarget(_ target:Any?, action:Selector, for events:UIControlEvents) {
        redShadeButton.addTarget(target, action: action, for: events)
    }
    
}
