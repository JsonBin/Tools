//
//  WBCalendarDateManager.swift
//  WBAlamofire
//
//  Created by zwb on 2017/4/7.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

open class WBCalendarDateManager {
    
    public typealias Component = Calendar.Component
   
    private let months: Int
    
    public init(maxMonths: Int) {
        months = maxMonths
    }
    
    /// 计算一共需要的月份数
    ///
    /// - Parameter maxMonth: 最多显示多少个月
    /// - Returns: 月份对应的时间
    open func monthWithYears() -> [String] {
        let calendar = Calendar.current
        
        let setComs = Set<Component>(arrayLiteral: .year, .month)
        let components = calendar.dateComponents(setComs, from: Date())
        
        var months = [String]()
        
        var year = components.year!
        var month = components.month!
        for _ in 0..<self.months {
            
            months.append("\(year)年\(month)月")
            
            month += 1
            
            if month > 12 {
                year += 1
                month = 1
            }
        }
        
        return months
    }
    
    /// 计算每个月有多少周或多少天
    ///
    /// - Parameter component: 计算条件
    /// - Returns: 周数或天数
    open func calculateInfoWithMonth(_ component: Component) -> [Int] {
        let calendar = Calendar.current
        
        let comps = Set<Component>(arrayLiteral: .year, .month, component)
        var components = calendar.dateComponents(comps, from: Date())
        
        var calculates = [Int]()
        
        for _ in 0..<months {
            
            // 用当月15号去找每个月的属性
            let year = components.year!
            let month = components.month!
            let day = "15"
            var dateString = String()
            if month >= 10 {
                dateString = "\(year)-\(month)-\(day)"
            }else{
                dateString = "\(year)-0\(month)-\(day)"
            }
            
            guard let date = dateString.beiJingTime() else {
                calculates.append(30)
                continue
            }
            // weeks or days
            let range = calendar.range(of: component, in: .month, for: date)!
            calculates.append(range.count)
            
            // next month
            components.month! += 1
            if components.month! > 12 {
                components.year! += 1
                components.month = 1
            }
        }
        
        return calculates
    }
    
    /// 计算每个月的第一周从第几天开始
    ///
    /// - Returns: 每月第一周天数
    open func calculateFirstDayOfWeekInMonth() -> [Int] {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        calendar.minimumDaysInFirstWeek = 1
        if let timezone = TimeZone(abbreviation: "UTC") {
            calendar.timeZone = timezone
        }
        
        var firstWeekDays = [Int]()
        
        // 当前时间月份的第一天是什么时候
        var startDate = Date()
        var interval: TimeInterval = 0
        _ = calendar.dateInterval(of: .month, start: &startDate, interval: &interval, for: Date())
        // 获得第一周从第几天开始
        guard var firstMonth = calendar.ordinality(of: .day, in: .weekOfMonth, for: startDate) else { return [] }
        
        // 取出每个月的天数和周数
        let weeks = self.calculateInfoWithMonth(.weekOfMonth)
        let days = self.calculateInfoWithMonth(.day)
        
        for index in 0..<self.months {
            firstWeekDays.append(firstMonth)
            
            // 算出最后一周几天
            var endWeekDay = days[index] - (7 - firstMonth + 1) - (weeks[index] - 2) * 7
            // 如果一周刚好7天结束，那么重置最后一周为0，下周从第一天开始计算
            if endWeekDay == 7 { endWeekDay = 0 }
            // 下一个月的第一周从第几天开始
            firstMonth = endWeekDay + 1
        }
        
        return firstWeekDays
    }
    
    /// 计算本月过期的天数和当前的日期为第几天
    ///
    /// - Returns: 已经过去的天数
    open class func expireDataCount() -> Int {
        let calendar = Calendar.current
        
        let comps = Set<Component>(arrayLiteral: .year, .month, .day)
        var components = calendar.dateComponents(comps, from: Date())
        
        return components.day! - 1
    }
    
    
    /// 计算两个日期之间间隔几天
    ///
    /// - Parameters:
    ///   - date1: 第一个日期
    ///   - date2: 第二个日期
    /// - Returns: 间隔天数
    open class func compare(_ date1:Date?, to date2: Date?) -> Int {
        guard let date1 = date1, let date2 = date2 else { return 0 }
        let timeInter1 = date1.timeIntervalSinceNow
        let timeInter2 = date2.timeIntervalSinceNow
        let distance = fabs(timeInter2 - timeInter1)
        return lround(distance / Double(24 * 60 * 60))
    }
}
