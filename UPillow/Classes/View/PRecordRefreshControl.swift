//
//  PRecordRefreshControl.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/24.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit
import JHPullToRefreshKit

class PRecordRefreshControl: JHLayerAnimationRefreshControl {
    
    var rotatingView:UIView!
    var colors:[UIColor]!
    var dots:[UIView]!
    var completion:Handler?
    
    override class func height() -> CGFloat {
        return 90
    }
    
    override class func animationDelay() -> TimeInterval {
        return 0
    }
    
    override class func animationDuration() -> TimeInterval {
        return 0.9
    }
    
    override func targetLayer() -> CALayer! {
        return rotatingView.layer
    }
    
    override func setup() {
        self.colors = [UIColor(r: 242, g: 105, b: 37, a: 1),
                       UIColor(r: 242, g: 105, b: 37, a: 0.9),
                       UIColor(r: 242, g: 105, b: 37, a: 0.8),
                       UIColor(r: 242, g: 105, b: 37, a: 0.7),
                       UIColor(r: 242, g: 105, b: 37, a: 0.6),
                       UIColor(r: 242, g: 105, b: 37, a: 0.5)]
        self.anchorPosition = .middle
        rotatingView = UIView.init(frame: CGRect(x: 0, y: 0, width: PRecordRefreshControl.height(), height: PRecordRefreshControl.height()))
        rotatingView.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: PRecordRefreshControl.height()/2)
        backgroundColor = Specs.color.clear
        rotatingView.backgroundColor = Specs.color.clear
        addCABasicAnimation(withKeyPath: "transform.rotation.z", fromValue: 0.0, toValue: CGFloat(2*Double.pi))
        var dotz = [UIView]()
        for i in 0 ..< 6 {
            dotz.append(dot(withIndex: i))
            self.rotatingView.addSubview(dotz[i])
        }
        self.dots = dotz
        self .addSubview(toRefreshAnimationView: self.rotatingView)
    }
    
    func dot(withIndex index:Int) -> UIView {
        let offset = CGFloat(20)
        let dot = UIView.init(frame: CGRect(x: 0, y: 0, width: 9, height: 9))
        dot.backgroundColor = self.colors[index]
        dot.layer.cornerRadius = dot.bounds.size.width/2
        dot.center = CGPoint(x: PRecordRefreshControl.height()/2.0 + offset*CGFloat(cosf(Specs.constant.radians + Float.pi*Float(index)/3)),
                             y: PRecordRefreshControl.height()/2.0 + offset*CGFloat(sinf(Specs.constant.radians + Float.pi*Float(index)/3))
        )
        return dot
    }
    
    override func handleScrolling(onAnimationView animationView: UIView!, withPullDistance pullDistance: CGFloat, pullRatio: CGFloat, pullVelocity: CGFloat) {
        
    }
    
    override func setupRefreshControl(forAnimationView animationView: UIView!) {
        
    }
    
    override func animationCycle(forAnimationView animationView: UIView!) {
        
    }
    
    override func exitAnimation(forRefreshView animationView: UIView!, withCompletion completion: JHCompletionBlock!) {
        UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: 0), animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4, animations: {
                var offset = CGFloat(20)
                for idx in 0 ..< 6 {
                    if idx == 0 || idx == 3 {
                        offset = CGFloat(35.0)
                    } else {
                        offset = CGFloat(50)
                    }
                    let dot = self.dots[idx]
                    dot.center = CGPoint(x: PRecordRefreshControl.height()/2.0 + offset*CGFloat(cosf(Specs.constant.radians + Float.pi*Float(idx)/3)),
                                         y: PRecordRefreshControl.height()/2.0 + offset*CGFloat(sinf(Specs.constant.radians + Float.pi*Float(idx)/3)))
                }
            })
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.3, animations: {
                for idx in 0 ..< 6 {
                    let dot = self.dots[idx]
                    dot.center = CGPoint(x: PRecordRefreshControl.height()/2.0,
                                         y: PRecordRefreshControl.height()/2.0)
                }
            })
            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.2, animations: {
                let dot = self.dots[5]
                dot.transform = CGAffineTransform(scaleX: Specs.constant.kScreenWidth*2/dot.height, y: PRecordRefreshControl.height()*4/dot.height)
            })
        }) { (finished) in
            self.rotatingView.alpha = 0.0
            self.backgroundColor = self.colors[5]
            completion?()
        }
    }
    
    override func resetAnimationView(_ animationView: UIView!) {
        let offset = CGFloat(20)
        rotatingView.alpha = 1.0
        backgroundColor = Specs.color.clear
        for i in 0 ..< 6 {
            let dot = self.dots[i]
            dot.center = CGPoint(x: PRecordRefreshControl.height()/2.0 + offset*CGFloat(cosf(Specs.constant.radians + Float.pi*Float(i)/3)),
                                 y: PRecordRefreshControl.height()/2.0 + offset*CGFloat(sinf(Specs.constant.radians + Float.pi*Float(i)/3)))
            dot.transform = .identity
        }
    }
    
}
