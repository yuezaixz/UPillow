//
//  Date+Extensions.swift
//  UPillow
//
//  Created by 吴迪玮 on 2017/8/8.
//  Copyright © 2017年 Podoon. All rights reserved.
//

import Foundation

public extension Date {
    
    /// Calculate remain time to human readable text
    ///
    /// - Parameter other: other date
    /// - Returns: human readable text
    func remainText(to date: Date) -> String {
        
        let remain = Int(timeIntervalSince1970 - date.timeIntervalSince1970)
        var minutes = Int(remain / 60)
        let hours = Int(minutes / 60)
        minutes = Int(minutes - hours * 60)
        
        let seconds = Int(remain - hours * 60 * 60 - minutes * 60)
        // Treat 1sec as 1min
        if seconds > 0 {
            minutes = minutes + 1
        }
        
        // Too special, should replace it with better approach
        let tableName = "Editor"
        
        if hours > 2 {
            return ""
        } else if hours > 0 && minutes > 0 {
            return String(format: Localized(key: "in %dh %dm", tableName: tableName), hours, minutes)
        } else if hours > 0 {
            return String(format: Localized(key: "in %dh", tableName: tableName), hours)
        } else if minutes > 0 {
            return String(format: Localized(key: "in %dm", tableName: tableName), minutes)
        }
        
        return ""
    }
    
    func dayText(timeOffset:Int) -> String {
        let timeZone = TimeZone.init(identifier: "UTC")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = "MM-dd"
        
        let resultDate = NSCalendar.current.date(byAdding: Calendar.Component.day, //Here you can add year, month, hour, etc.
            value: timeOffset,  //Here you can add number of units
            to: self as Date)
        
        let date = formatter.string(from: resultDate!)
        return date.components(separatedBy: " ").first!
    }
    
    /// Return the beginning of next hour
    ///
    /// - Returns: next hour
    func nextHour() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: self)
        if let hour = components.hour {
            components.hour = hour + 1
        }
        return calendar.date(from: components) ?? self
    }
    
    func yesterday() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: self)
        if let day = components.day {
            components.day = day - 1
        }
        return calendar.date(from: components) ?? self
    }
    
    /// Get days between two dates
    ///
    /// - Parameter other: other date
    /// - Returns: days
    func daysBetween(other: Date) -> Int {
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: other)
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day ?? 0
    }
}
