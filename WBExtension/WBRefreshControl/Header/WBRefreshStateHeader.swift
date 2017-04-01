//
//  WBRefreshStateHeader.swift
//  WBExtension
//
//  Created by zwb on 17/3/9.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

/// 下拉刷新父视图
open class WBRefreshStateHeader: WBRefreshHeader {
    
    /// 使用该closure来决定显示更新时间的文字
    open var lastUpdatedTimeTextClosure: ((_ lastUpdateTime:Date) -> String)?
    
    /// 显示上一次刷新时间的label
    open var lastUpdatedTimeLabel: UILabel {
        guard let label = _lastUpdatedTimeLabel else {
            _lastUpdatedTimeLabel = UILabel.wb_label
            addSubview(_lastUpdatedTimeLabel)
            return _lastUpdatedTimeLabel
        }
        return label
    }
    private var _lastUpdatedTimeLabel: UILabel!
    
    /// 文字距离圈圈、箭头的距离
    open var labelLeftInset: CGFloat = 0
    
    /// 显示刷新状态的label
    open var stateLabel: UILabel! {
        guard let label = _stateLabel else {
            _stateLabel = UILabel.wb_label
            addSubview(_stateLabel)
            return _stateLabel
        }
        return label
    }
    private var _stateLabel: UILabel!
    
    /// 私有存储所有状态对应的文字
    private typealias titleState = WBRefresh.State
    private var stateTitles = [titleState:String]()
    
    /// 设置state状态下的文字
    ///
    /// - Parameters:
    ///   - title: 文字
    ///   - state: 状态
    open func setTitle(_ title:String?, forState wbState:WBRefresh.State) -> Void {
        if title == nil { return }
        stateTitles[wbState] = title!
        stateLabel.text = stateTitles[state]
    }
    
    // MARK: - 获取系统日历
    
    private var currentCalendar: Calendar {
        if Calendar.ReferenceType.responds(to: Selector(("calendarWithIdentifier"))) {
            return Calendar(identifier: .gregorian)
        }
        return Calendar.current
    }
    
    // MARK: - 重写父类
    open override func prepare() {
        super.prepare()
        
        // 初始化间距
        labelLeftInset = WBRefresh.Float.labelLeftInset.rawValue
        
        // 初始化文字
        setTitle(Bundle.wb_localizedStringForKey(WBRefresh.HeaderText.default.rawValue), forState: .default)
        setTitle(Bundle.wb_localizedStringForKey(WBRefresh.HeaderText.pulling.rawValue), forState: .pulling)
        setTitle(Bundle.wb_localizedStringForKey(WBRefresh.HeaderText.refreshing.rawValue), forState: .refreshing)
    }
    
    open override func placeSubviews() {
        super.placeSubviews()
        
        if stateLabel.isHidden { return }
        
        let noConstrainsOnStateLabel = stateLabel.constraints.count == 0
        
        if lastUpdatedTimeLabel.isHidden {
            // 状态
            if noConstrainsOnStateLabel {
                stateLabel.frame = bounds
            }
        }else{
            let stateLabelHeight = ve.height * 0.5
            // 状态
            if noConstrainsOnStateLabel {
                stateLabel.ve.x = 0
                stateLabel.ve.y = 0
                stateLabel.ve.width = ve.width
                stateLabel.ve.height = stateLabelHeight
            }
            
            // 更新时间
            if lastUpdatedTimeLabel.constraints.count == 0{
                lastUpdatedTimeLabel.ve.x = 0
                lastUpdatedTimeLabel.ve.y = stateLabelHeight
                lastUpdatedTimeLabel.ve.width = ve.width
                lastUpdatedTimeLabel.ve.height = ve.height - lastUpdatedTimeLabel.ve.y
            }
        }
    }
    
    open override func setState(_ refreshState: WBRefresh.State) {
        if refreshState == state { return }
        
        super.setState(refreshState)
        
        // 设置文字
        stateLabel.text = stateTitles[state]
        
        // 重新设置key(重新显示时间)
        lastUpdatedTimeKey = lastUpdatedTimeKey
    }
    
    // MARK: - 对key值的重新处理
    
    open override func setLastUpdateKey(_ lastKey: String) {
        super.setLastUpdateKey(lastKey)
        
        // 如果没显示，直接返回
        if lastUpdatedTimeLabel.isHidden { return }
        
        let lastTime = UserDefaults.standard.object(forKey: lastKey)
        
        // 如果有closure
        if let lastClosure = lastUpdatedTimeTextClosure {
            if let last = lastTime {
                lastUpdatedTimeLabel.text = lastClosure(last as! Date)
            }
            return
        }
        
        if let last = lastTime {
            // 获取年月日
            let calendar = currentCalendar
            let unitFlags:Set<Calendar.Component> = [.year, .month, .day, .hour]
            let compare1 = calendar.dateComponents(unitFlags, from: last as! Date)
            let compare2 = calendar.dateComponents(unitFlags, from: Date())
            
            // 格式化日期
            let formatter = DateFormatter()
            var isToday = false
            if compare1.day == compare2.day {
                // 今天
                formatter.dateFormat = " HH:mm"
                isToday = true
            }else if compare1.year == compare2.year {
                // 今年
                formatter.dateFormat = "MM-dd HH:mm"
            }else{
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
            }
            let time = formatter.string(from: last as! Date)
            
            // 显示日期
            let willSetTime = Bundle.wb_localizedStringForKey(WBRefresh.HeaderText.lastTimeKey.rawValue) + (isToday ? Bundle.wb_localizedStringForKey(WBRefresh.HeaderText.dateToday.rawValue) : "") + time
            lastUpdatedTimeLabel.text = willSetTime
        }else{
            let willSetTime = Bundle.wb_localizedStringForKey(WBRefresh.HeaderText.lastTimeKey.rawValue) + Bundle.wb_localizedStringForKey(WBRefresh.HeaderText.noneLastDate.rawValue)
            lastUpdatedTimeLabel.text = willSetTime
        }
    }
}
