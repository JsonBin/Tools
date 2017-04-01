//
//  WBRefresh.swift
//  WBExtension
//
//  Created by zwb on 17/3/9.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

/// 设置刷新框架的属性集合类

public struct WBRefresh {
    
    /// kvo 字典
    public typealias Dictionary = [NSKeyValueChangeKey : Any]
    
    // MARK: - 刷新状态
    
    /// 刷新控件的状态
    ///
    /// - `default`: 正常状态
    /// - pulling: 下拉状态
    /// - refreshing: 正在刷新
    /// - willRefresh: 将要刷新
    /// - noMoreData: 加载完毕
    public enum State: UInt8 {
        case `default`
        case pulling
        case refreshing
        case willRefresh
        case noMoreData
    }
    
    // MARK: - 回调
    
    /// 刷新的回调
    public typealias Closure = () -> Void
    
    /// 刷新调用的回调
    public struct ComponentClosure {
        /// 进入刷新
        public typealias refreshing = Closure
        /// 开始刷新
        public typealias begin = Closure
        /// 刷新结束后
        public typealias end = Closure
    }
    
    /// 刷新调用的回调
    ///
    /// - refreshing: 进入刷新
    /// - begin: 开始刷新
    /// - end: 刷新结束后
//    public enum ComponentClosure {
//        case refreshing(closure: Closure)
//        case begin(closure: Closure)
//        case end(closure: Closure)
//    }
    
    // MARK: - 属性设置
    
    /// 设置的默认属性
    ///
    /// - labelLeftInset: label左边距离
    /// - header: header默认高度
    /// - footer: footer默认高度
    public enum Float: CGFloat {
        case labelLeftInset = 25.0
        case header = 54.0
        case footer = 44.0
    }
    
    // MARK: - 动画时间长度
    
    /// 动画的时间长度
    ///
    /// - fast: 快速
    /// - slow: 慢速
    public enum Animation: TimeInterval {
        case fast = 0.25
        case slow = 0.4
    }
    
    // MARK: - Label属性
    
    /// 刷新控件Label的属性
    public struct Label {
        /// 文字颜色
        public static let textColor = WBRefresh.RGBColor(r: 90, g: 90, b: 90)
        /// 字体大小
        public static let font = UIFont.systemFont(ofSize: 14)
    }
    
    // MARK: - 属性监听KVO
    
    /// scrollview的属性监听者
    ///
    /// - contentOffset: offset
    /// - contentInset: inset
    /// - contensSize: size
    /// - panState: 手势
    public enum KeyPath: String {
        case contentOffset = "contentOffset"
        case contentInset = "contentInset"
        case contentSize = "contentSize"
        case panState = "state"
    }
    
    // MARK: - 下拉刷新设置属性
    
    /// 下拉刷新的文字key
    ///
    /// - lastUpdateTimeKey: 上次刷新时间的key
    /// - `default`: 默认状态的key
    /// - pulling: 下拉刷新的key
    /// - refreshing: 正在刷新的key
    public enum HeaderText: String {
        case lastUpdateTimeKey = "WBRefreshHeaderLastUpdateTimeKey"
        case `default` = "WBRefreshHeaderDefaultText"
        case pulling = "WBRefreshHeaderPullingText"
        case refreshing = "WBRefreshHeaderRefreshingText"
        
        case lastTimeKey = "WBRefreshHeaderLastTimeText"
        case dateToday = "WBRefreshHeaderDateTodayText"
        case noneLastDate = "WBRefreshHeaderNoneLastDateText"
    }
    
    /// 上拉加载的属性
    public struct FooterText {
        
        /// 常规的文字key
        ///
        /// - `default`: 默认状态key
        /// - refresh: 刷新状态key
        /// - noMoreData: 无更多数据key
        public enum Auto: String {
            case `default` = "WBRefreshAutoFooterDefaultText"
            case refresh = "WBRefreshAutoFooterRefreshingText"
            case noMoreData  = "WBRefreshAutoFooterNoMoreDataText"
        }
        
        /// 自动回弹的文字key
        ///
        /// - `default`: 默认状态key
        /// - pulling: 即将刷新key
        /// - refresh: 刷新时的key
        /// - noMoreData: 无更多数据key
        public enum Back: String {
            case `default` = "WBRefreshBackFooterDefaultText"
            case pulling = "WBRefreshBackFooterPullingText"
            case refresh = "WBRefreshBackFooterRefreshingText"
            case noMoreData = "WBRefreshBackFooterNoMoreDataText"
        }
    }
    
    /// RGB颜色
    ///
    /// - Parameters:
    ///   - red: red
    ///   - green: green
    ///   - blue: blue
    /// - Returns: UIColor
    public static func RGBColor(r red:CGFloat,g green:CGFloat,b blue:CGFloat) -> UIColor{
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
}

// MARK: - WBRefresh ComponentClosure

//public extension WBRefresh.ComponentClosure {
//    
//    ///  The `Closure` associated with the error. (设置正在刷新的回调)
//    public var refreshing: WBRefresh.Closure? {
//        switch self {
//        case .refreshing(closure: let block):
//            return block
//        default:
//            return nil
//        }
//    }
//    
//    ///  The `Closure` associated with the error. (设置开始刷新的回调)
//    public var begin: WBRefresh.Closure? {
//        switch self {
//        case .begin(closure: let block):
//            return block
//        default:
//            return nil
//        }
//    }
//    
//    ///  The `Closure` associated with the error. (设置刷新完成后的回调)
//    public var end: WBRefresh.Closure? {
//        switch self {
//        case .end(closure: let block):
//            return block
//        default:
//            return nil
//        }
//    }
//}

// MARK: - WBRefresh Label Properties

//public extension WBRefresh.Label {
//    
//    /// The `Label` default textColor. (设置label的默认字体颜色)
//    public var textColor: UIColor? {
//        switch self {
//        case .textColor(color: _):
//            return WBRefresh.RGBColor(r: 90, g: 90, b: 90)
//        default:
//            return nil
//        }
//    }
//    
//    /// The `Label` default font. (设置label的默认字体大小)
//    public var font: UIFont? {
//        switch self {
//        case .font(font: _):
//            return UIFont.systemFont(ofSize: 14)
//        default:
//            return nil
//        }
//    }
//}
