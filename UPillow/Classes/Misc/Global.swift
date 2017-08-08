//
//  Global.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/8.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import Foundation

// MARK: - Closures
public typealias Handler = () -> ()

// MARK: - Convenience dispatch API

/// Perform closure after delay
///
/// - Parameters:
///   - sec: seconds
///   - handler: closure
public func performAfterDelay(sec: TimeInterval, handler: @escaping Handler) {
    DispatchQueue.main.asyncAfter(deadline: .now() + sec) {
        handler()
    }
}

/// Perform closure on global background thread
///
/// - Parameter handler: closure
public func performOnBackground(handler: @escaping Handler) {
    DispatchQueue.global(qos: .background).async {
        handler()
    }
}

/// Perform closure on main thread
///
/// - Parameter handler: closure
public func performOnMainThread(handler: @escaping Handler) {
    if Thread.current.isMainThread {
        handler()
    } else {
        DispatchQueue.main.async {
            handler()
        }
    }
}

/// Override
///
/// - Parameter key: key
/// - Returns: Localized string
public func Localized(key: String, tableName: String? = "Localizable") -> String {
    return NSLocalizedString(key, tableName: tableName, comment: "")
}
