//
//  PImageDrawUtil.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/18.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit

enum ArrowType{
    case left
    case right
}

class PImageDrawUtil {
    struct Cache {
        static var imageOfCheckmark: UIImage?
        static var imageOfCross: UIImage?
        static var imageOfInfo: UIImage?
    }
    class func drawNoticeImage(_ type: NoticeType) {
        let checkmarkShapePath = UIBezierPath()
        
        // draw circle
        checkmarkShapePath.move(to: CGPoint(x: 36, y: 18))
        checkmarkShapePath.addArc(withCenter: CGPoint(x: 18, y: 18), radius: 17.5, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
        checkmarkShapePath.close()
        
        switch type {
        case .success: // draw checkmark
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 18))
            checkmarkShapePath.addLine(to: CGPoint(x: 16, y: 24))
            checkmarkShapePath.addLine(to: CGPoint(x: 27, y: 13))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 18))
            checkmarkShapePath.close()
        case .error: // draw X
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 10))
            checkmarkShapePath.addLine(to: CGPoint(x: 26, y: 26))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 26))
            checkmarkShapePath.addLine(to: CGPoint(x: 26, y: 10))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 10))
            checkmarkShapePath.close()
        case .info:
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 6))
            checkmarkShapePath.addLine(to: CGPoint(x: 18, y: 22))
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 6))
            checkmarkShapePath.close()
            
            UIColor.white.setStroke()
            checkmarkShapePath.stroke()
            
            let checkmarkShapePath = UIBezierPath()
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 27))
            checkmarkShapePath.addArc(withCenter: CGPoint(x: 18, y: 27), radius: 1, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
            checkmarkShapePath.close()
            
            UIColor.white.setFill()
            checkmarkShapePath.fill()
        }
        
        UIColor.white.setStroke()
        checkmarkShapePath.stroke()
    }
    
    class var imageOfCheckmark: UIImage {
        if (Cache.imageOfCheckmark != nil) {
            return Cache.imageOfCheckmark!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
        
        PImageDrawUtil.drawNoticeImage(NoticeType.success)
        
        Cache.imageOfCheckmark = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfCheckmark!
    }
    class var imageOfCross: UIImage {
        if (Cache.imageOfCross != nil) {
            return Cache.imageOfCross!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
        
        PImageDrawUtil.drawNoticeImage(NoticeType.error)
        
        Cache.imageOfCross = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfCross!
    }
    class var imageOfInfo: UIImage {
        if (Cache.imageOfInfo != nil) {
            return Cache.imageOfInfo!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
        
        PImageDrawUtil.drawNoticeImage(NoticeType.info)
        
        Cache.imageOfInfo = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfInfo!
    }
    
    class func drawArrowImage(_ type: ArrowType) {
        let checkmarkShapePath = UIBezierPath()
        
        switch type {
        case .left:
            checkmarkShapePath.move(to: CGPoint(x: 11, y: 0))
            checkmarkShapePath.addLine(to: CGPoint(x: 1, y: 20))
            checkmarkShapePath.addLine(to: CGPoint(x: 11, y: 40))
        case .right:
            checkmarkShapePath.move(to: CGPoint(x: 1, y: 0))
            checkmarkShapePath.addLine(to: CGPoint(x: 11, y: 20))
            checkmarkShapePath.addLine(to: CGPoint(x: 1, y: 40))
        }
        
        Specs.color.gray.setStroke()
        checkmarkShapePath.lineWidth = 2.0
        checkmarkShapePath.stroke()
    }
    
    class var imageOfLeftArrow: UIImage {//左右箭头，不缓存，因为不常用
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 12, height: 40), false, 0)
        
        PImageDrawUtil.drawArrowImage(.left)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    class var imageOfRightArrow: UIImage {//左右箭头，不缓存，因为不常用
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 12, height: 40), false, 0)
        
        PImageDrawUtil.drawArrowImage(.right)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
