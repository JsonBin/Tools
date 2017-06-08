//
//  WBExtensions.swift
//  WBAlamofire
//
//  Created by zwb on 2017/4/11.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit

// MARK: - Date
extension Date {
    
    // 统一日历格式
    public func calendarDateToString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(identifier: "Asia/Beijing")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}

// MARK: - String
extension String {
    
    // 统一日历格式
    public func calendarStringToDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(identifier: "Asia/Beijing")
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.date(from: self)
    }
    
    // 转为北京时间
    public func beiJingTime() -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(identifier: "Asia/Beijing")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)
    }
    
    public func convertStringToString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(identifier: "Asia/Beijing")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: self)
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date!)
    }
    
    // 倒计时时间转换，超时时间到与现在之间的时间错差
    public func calculateOutTimeInterval() -> TimeInterval? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(identifier: "Asia/Beijing")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: self)
        return date?.timeIntervalSinceNow
    }
    
    /// 将不同的日期格式转为统一的日期格式
    public func unityFormattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(identifier: "Asia/Beijing")
        formatter.dateFormat = "yyyy年MM月dd日"
        let date = formatter.date(from: self)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date!)
    }
    
    /// 系统消息日期格式
    public func sysmsgFormatted() -> String? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(identifier: "Asia/Beijing")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: self)
        formatter.dateFormat = "yy/MM/dd"
        if let timeDate = date {
            return formatter.string(from: timeDate)
        }
        return nil
    }
}

// 打印日志
public func CalendarLogs<T>(_ message:T, file File:NSString = #file, method Method:String = #function, line Line:Int = #line) -> Void {
    if WBAlConfig.shared.debugLogEnable {
        #if DEBUG
            print("<\(File.lastPathComponent)>{Line:\(Line)}-[\(Method)]:\(message)")
        #endif
    }
}
