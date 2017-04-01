//
//  DateExtension.swift
//  HSDashedLine
//
//  Created by zwb on 17/2/7.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit


public extension Date {
    
    
    // MARK: - 时间戳转为String时间
    
    /**
     标准时间日期描述
     
     - parameter time: 时间
     
     - returns: 标准时间   上午9:03或下午4:30
     */
    @discardableResult
    public static func stringWithTimeInterval(_ time:Double) -> String {
        
        return dateWithTimeIntervalInMilliSecondSince1970(time).formattenTime()
    }
    
    /**
     格式化日期描述，距离当前时间间隔为多久
     
     - parameter time: 时间戳
     
     - returns: 距离当前时间间隔   1分钟前或9个小时前
     */
    @discardableResult
    public static func formattedTimeFromTimeInterval(_ time: Double) -> String {
        
        return dateWithTimeIntervalInMilliSecondSince1970(time).formattedDateDescription()
    }
    
    /**
     格式化日期 eg:  2018-02-19
     
     - parameter time: 时间
     
     - returns:
     */
    @discardableResult
    public static func formattedDate(_ time:Double) -> String {
        
        return dateWithTimeIntervalInMilliSecondSince1970(time).dateToString()
    }
    
    /**
     标准格式化日期  eg: 2016-05-08 06:57
     
     - parameter time: 时间
     
     - returns:
     */
    @discardableResult
    public static func formattedNormalDate(_ time:Double) -> String {
        return dateWithTimeIntervalInMilliSecondSince1970(time).dateToNormalString()
    }
    
    // MARK: - Date转为String时间
    
    public func dateToNormalString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: self)
    }
    
    /* 时间戳装化为标准时间 */
    public func dateToString() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    // MARK: - Private Methods
    
    private static func dateWithTimeIntervalInMilliSecondSince1970(_ timeIntervalInMilliSecond:Double) -> Date {
        
        var rect:Date?  =  nil
        
        var timeInterval:Double = timeIntervalInMilliSecond
        
        if timeIntervalInMilliSecond>140000000000 {
            
            timeInterval = timeIntervalInMilliSecond/1000
        }
        
        rect = Date(timeIntervalSince1970: timeInterval)
        
        return rect!
        
    }
    
    /*格式化日期描述,距离当前时间间隔描述*/
    private func formattedDateDescription() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let theDay = dateFormatter.string(from: self)
        let currentDay = dateFormatter.string(from: Date())
        
        let timeInterval = 0-self.timeIntervalSinceNow
        
        if timeInterval<60 {
            // 1分钟以内
            return "刚刚"
        }else if timeInterval<3600{
            // 1小时以内
            return String(format: "%.f分钟前", timeInterval/60)
        }else if timeInterval<21600{
            // 6小时以内
            return String(format: "%.f小时前", timeInterval/3600)
        }else if theDay == currentDay{
            // 当天
            dateFormatter.dateFormat = "HH:mm"
            return String(format: "今天 %@", dateFormatter.string(from: self))
            
        }else if dateFormatter.date(from: currentDay)!.timeIntervalSince(dateFormatter.date(from: theDay)!) == 86400{
            // 昨天
            dateFormatter.dateFormat = "HH:mm"
            return String(format: "昨天 %@", dateFormatter.string(from: self))
        }else if dateFormatter.date(from: currentDay)!.timeIntervalSince(dateFormatter.date(from: theDay)!) == 86400*2{
            // 前天
            dateFormatter.dateFormat = "HH:mm"
            return String(format: "前天 %@", dateFormatter.string(from: self))
        }/*else if timeInterval<2592000{
            // 以前 30天以内
            dateFormatter.dateFormat = "HH:mm"
            let day = String(format: "%.f天前", timeInterval/86400)
            let time = dateFormatter.string(from: self)
            return String(format: "%@ %@", day, time)
        }*/else{
            // 以前 30天以外
            dateFormatter.dateFormat = "yy/MM/dd HH:mm"
            return dateFormatter.string(from: self)
        }
    }
    
    private func formattenTime() -> String{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let dateNow:NSString = formatter.string(from: Date()) as NSString
        var components = DateComponents()
        components.day = (dateNow.substring(with: NSMakeRange(8, 2)) as NSString).integerValue
        components.month = (dateNow.substring(with: NSMakeRange(5, 2)) as NSString).integerValue
        components.year = (dateNow.substring(with: NSMakeRange(0, 4)) as NSString).integerValue
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = gregorian.date(from: components)  // 今天 0 点
        
        let ti = self.timeIntervalSince(date!)
        let hour:NSInteger = NSInteger(ti)/3600
        
        let dateFormatter = DateFormatter()
        let formatStringForHours = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)! as NSString
        let containsA = formatStringForHours.range(of: "a")
        let hasAMPM:Bool = containsA.location !=  NSNotFound
        
        if !hasAMPM {  // 24小时制
            
            if hour <= 24 && hour >= 0 {
                
                dateFormatter.dateFormat = "HH:mm"
            }else if hour<0 && hour >=  -24{
                dateFormatter.dateFormat = "昨天HH:mm"
            }else{
                dateFormatter.dateFormat = "yy/MM/dd HH:mm"
            }
        }else{   // 12小时制
            if hour >= 0 && hour <= 6{
                
                dateFormatter.dateFormat = "凌晨HH:mm"
            }else if hour > 6 && hour <= 11{
                
                dateFormatter.dateFormat = "上午HH:mm"
            }else if hour > 11 && hour <= 17{
                
                dateFormatter.dateFormat = "下午HH:mm"
            }else if hour > 17 && hour <= 24{
                
                dateFormatter.dateFormat = "晚上HH:mm"
            }else if hour < 0 && hour >= -24{
                
                dateFormatter.dateFormat = "昨天HH:mm"
            }else{
                
                dateFormatter.dateFormat = "yy/MM/dd HH:mm"
            }
            
        }
        
        let rect = dateFormatter.string(from: self)
        return rect
    }
}
