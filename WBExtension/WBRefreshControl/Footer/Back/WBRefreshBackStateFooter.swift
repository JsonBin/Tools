//
//  WBRefreshBackStateFooter.swift
//  WBExtension
//
//  Created by zwb on 17/3/14.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

/// 刷新完自动回弹的footer父类
open class WBRefreshBackStateFooter : WBRefreshBackFooter {
    
    /// 文字距离菊花、箭头的距离
    open var  labelLeftInset: CGFloat = 0
    
    /// 显示刷新文字的label
    open var stateLabel: UILabel {
        if let label = _stateLabel{
            return label
        }
        _stateLabel = UILabel.wb_label
        addSubview(_stateLabel)
        return _stateLabel
    }
    private var _stateLabel: UILabel!
    
    /// 存取所有状态对应的文字
    private typealias titleState = WBRefresh.State
    private var stateTitles = [titleState: String]()
    
    /// 设置state状态的文字
    ///
    /// - Parameters:
    ///   - title: 文字
    ///   - state: 状态
    open func setTitle(_ title:String?, forState sta:WBRefresh.State) -> Void {
        if title == nil { return }
        stateTitles[sta] = title!
        stateLabel.text = stateTitles[state]
    }
    
    /// 获取state下的title文字
    ///
    /// - Parameter state: 状态
    /// - Returns: title文字
    open func titleForState(_ state:WBRefresh.State) -> String {
        return stateTitles[state]!
    }
    
    // MARK: - 重写父类
    open override func prepare() {
        super.prepare()
        
        // 初始化间距
        labelLeftInset = WBRefresh.Float.labelLeftInset.rawValue
        
        // 初始化文字
        setTitle(Bundle.wb_localizedStringForKey(WBRefresh.FooterText.Back.default.rawValue), forState: .default)
        setTitle(Bundle.wb_localizedStringForKey(WBRefresh.FooterText.Back.pulling.rawValue), forState: .pulling)
        setTitle(Bundle.wb_localizedStringForKey(WBRefresh.FooterText.Back.refresh.rawValue), forState: .refreshing)
        setTitle(Bundle.wb_localizedStringForKey(WBRefresh.FooterText.Back.noMoreData.rawValue), forState: .noMoreData)
    }
    
    open override func placeSubviews() {
        super.placeSubviews()
        
        if stateLabel.constraints.count != 0 { return }
        
        // 设置frame
        stateLabel.frame = bounds
    }
    
    open override func setState(_ refreshState: WBRefresh.State) {
        if refreshState == state { return }
        
        super.setState(refreshState)
        
        // 设置文字
        stateLabel.text = stateTitles[state]
    }
}


