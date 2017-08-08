//
//  UIView+Extension.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/8.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit

// MARK: - Convenience methods for UIView
public extension UIView {
    
    // MARK: - Convenience frame methods
    var width: CGFloat {
        return frame.width
    }
    
    var height: CGFloat {
        return frame.height
    }
    
    var x: CGFloat {
        return frame.minX
    }
    
    var y: CGFloat {
        return frame.minY
    }
    
    var size: CGSize {
        return frame.size
    }
    
    convenience init(color: UIColor) {
        self.init()
        backgroundColor = color
    }
    
    func clipsToBoundsAndRasterize() {
        clipsToBounds = true
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

