//
//  PStatusChartView.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/18.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import UIKit

let kStatusLabelWidth = 40
let kStatusLabelHeight = 25
let kStatusLineWidth = 5
let kStatusPadding = 10

struct PStatusData {
    var startTime:Date
    var duration:Int
    var statusLabels:[String]
    var statusColors:[UIColor]
    var items:[Int]
    
    var statusCount:Int {
        get {
            return statusLabels.count
        }
    }
    
    func statusColorBy(statusIndex:Int) -> UIColor {
        return statusColors[statusIndex]
    }
    
    func statusLabelBy(statusIndex:Int) -> String {
        return statusLabels[statusIndex]
    }
    
}

struct PStatusLine {
    var color:UIColor
    var startPoint:CGPoint
    var endPoint:CGPoint {
        get {
            return CGPoint(x: startPoint.x+width, y: startPoint.y)
        }
    }
    var width:CGFloat
    
    var lastItemStatus:Int
    var statusCount:Int
    var lastIndex:Int
}

class PStatusChartView: UIView {
    @IBOutlet weak var chartView: UIView!
    private var chartViewPathLayers: [CAShapeLayer] = []
    @IBOutlet weak var chartViewHeight: NSLayoutConstraint!
    
    public var data:PStatusData?
    private var labels:[UILabel] = []
    private var _lineSpaceWidth:CGFloat {
        get {
            return chartView.width - (kStatusLabelWidth + kStatusPadding).cgFloat
        }
    }
    
    public var statusViewHeight:CGFloat {
        get {
            guard let data = self.data else {
                return 0
            }
            return (20 + data.statusCount * 40).cgFloat
        }
    }
    
    override func awakeFromNib() {
        
    }
    
    func initializeBy(headerHeight:CGFloat, data:PStatusData) {
        self.data = data
        
        //如果有，先清空
        for subView in chartView.subviews {
            subView.removeFromSuperview()
        }
        for chartLayer in chartViewPathLayers {
            chartLayer.removeFromSuperlayer()
        }
        chartViewPathLayers.removeAll()
        labels.removeAll()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if chartViewPathLayers.isEmpty {//如果没有绘制，就绘制。设定为只绘制一次
            loadLabelBy(data: self.data!)
            loadItemsBy(data: self.data!)
        }
    }
    
    private func loadLabelBy(data:PStatusData) {
        for (index,labelStr) in data.statusLabels.enumerated() {
            let label = UILabel(frame: CGRect(x: 12, y: 20+index*(25+20), width: kStatusLabelWidth, height: kStatusLabelHeight))
            label.font = Specs.font.large
            label.textColor = Specs.color.white
            label.text = labelStr
            label.textAlignment = .left
            labels.append(label)
            chartView.addSubview(label)
        }
    }
    
    private func loadItemsBy(data:PStatusData) {
        let itemsCount = data.items.count
        let scale = _lineSpaceWidth / itemsCount.cgFloat
        let lines = data.items.reduce([PStatusLine]()){ result,itemStatue in
            var newResult = result
            if newResult.isEmpty {
                if let currentLine = statusLineBy(itemStatue: itemStatue, scale: scale, itemIndex: 0, data: data) {
                    newResult.append(currentLine)
                }
            } else {
                if var lastLine = newResult.last,let currentLine = statusLineBy(itemStatue: itemStatue, scale: scale, itemIndex: lastLine.lastIndex+1, data: data) {
                    if lastLine.lastItemStatus == currentLine.lastItemStatus {
                        lastLine.lastIndex = currentLine.lastIndex
                        lastLine.statusCount += currentLine.statusCount
                        //线条宽度为5，及计数为5时候，才画一个点
                        
                        lastLine.width = scale * max(lastLine.statusCount - kStatusLineWidth + 1, 0).cgFloat
                        newResult.removeLast()
                        newResult.append(lastLine)
                    } else {
                        newResult.append(currentLine)
                    }
                }
            }
            return newResult
        }
        drawBy(lines: lines, data: data)
    }
    
    private func drawBy(lines:[PStatusLine], data:PStatusData) {
        for (colorIndex,color) in data.statusColors.enumerated() {
            let chartViewPathLayer = CAShapeLayer.init()
            let statusPath = UIBezierPath()
            let drawinglines = lines.filter { (line) -> Bool in
                return line.lastItemStatus == colorIndex
            }
            for line in drawinglines {
                statusPath.move(to: line.startPoint)
                statusPath.addLine(to: line.endPoint)
            }
            chartViewPathLayer.strokeColor = color.cgColor
            chartViewPathLayer.lineWidth = kStatusLineWidth.cgFloat
            chartViewPathLayer.lineJoin = kCALineJoinRound
            chartViewPathLayer.lineCap = kCALineCapRound
            chartViewPathLayer.path = statusPath.cgPath
            chartViewPathLayers.append(chartViewPathLayer)
            self.chartView.layer.addSublayer(chartViewPathLayer)
        }
        
    }

    private func statusLineBy(itemStatue:Int, scale:CGFloat, itemIndex:Int, data:PStatusData) -> PStatusLine? {
        guard labels.count > itemStatue else {
            return nil
        }
        return PStatusLine(color: data.statusColorBy(statusIndex: itemStatue),
                           startPoint: CGPoint(x: (kStatusLabelWidth+kStatusPadding).cgFloat + scale * itemIndex.cgFloat, y: labels[itemStatue].center.y),
                           width: 0.cgFloat,
                           lastItemStatus: itemStatue,
                           statusCount: 1,
                           lastIndex:itemIndex
        )
    }
    
}
