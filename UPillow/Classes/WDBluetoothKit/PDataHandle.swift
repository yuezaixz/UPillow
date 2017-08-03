//
//  PDataHandle.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/3.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import Foundation

public protocol PDataHandleDelegate: class {
    
    func notifyPillow(majorVersion:Int, minorVersion:Int, reVersion:Int)
    
}

public class PDataHandle {
    
    static let shareInstance: PDataHandle = PDataHandle()
    
    public weak var delegate: PDataHandleDelegate?
    
    public func handleReceivedData(_ receivedData: Data) {
//        let dataLength = receivedData.count
        let dataType = receivedData[0]
        let subDataType = receivedData[1]
        
        if dataType == Int(Character("V").unicodeScalars.first!.value) && subDataType == Int(Character("N").unicodeScalars.first!.value) {
            if let result = String.init(data: receivedData, encoding: .utf8) {
                
                let majorVersion = hexTodec(number:result.substring(with: 3..<5))
                let minorVersion = hexTodec(number:result.substring(with: 5..<7))
                let reVersion = hexTodec(number:result.substring(with: 7..<9))
                delegate?.notifyPillow(majorVersion: majorVersion, minorVersion: minorVersion, reVersion: reVersion)
            }
        }
    }
    
    func hexTodec(number num:String) -> Int {
        let str = num.uppercased()
        var sum = 0
        for i in str.utf8 {
            sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
            if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
                sum -= 7
            }
        }
        return sum
    }
}
