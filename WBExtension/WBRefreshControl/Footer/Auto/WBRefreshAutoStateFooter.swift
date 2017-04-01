//
//  WBRefreshAutoStateFooter.swift
//  WBExtension
//
//  Created by zwb on 17/3/14.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

/// 常规上拉加载父类
open class WBRefreshAutoStateFooter :  WBRefreshAutoFooter {
    
    /// 文字距离菊花、箭头的距离
    open var labelLeftInset: CGFloat = 0
    
    /// 显示状态的label
    open var stateLabel: UILabel {
        if let label = _stateLabel{
            return label
        }
        _stateLabel = UILabel.wb_label
        addSubview(_stateLabel)
        return _stateLabel
    }
    private var _stateLabel: UILabel!
    
    /// 隐藏刷新状态时的文字
    open var refreshingTitleHidden: Bool = false
    
    /// 所有状态对应的文字
    private typealias titleState = WBRefresh.State
    private var stateTitles = [titleState:String]()
    
    /// 设置state对应的文字
    ///
    /// - Parameters:
    ///   - title: 文字
    ///   - wbState: 状态
    open func setTitle(_ title:String?, forState wbState:WBRefresh.State) -> Void {
        if title == nil { return }
        stateTitles[wbState] = title!
        stateLabel.text = stateTitles[state]
    }
    
    // MARK: - 重写父类
    open override func prepare() {
        super.prepare()
        
        // 初始化间距
        labelLeftInset = WBRefresh.Float.labelLeftInset.rawValue
        
        // 初始化文字
        setTitle(Bundle.wb_localizedStringForKey(WBRefresh.FooterText.Auto.default.rawValue), forState: .default)
        setTitle(Bundle.wb_localizedStringForKey(WBRefresh.FooterText.Auto.refresh.rawValue), forState: .refreshing)
        setTitle(Bundle.wb_localizedStringForKey(WBRefresh.FooterText.Auto.noMoreData.rawValue), forState: .noMoreData)
        
        // 设置对label的操作
        stateLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(stateLabelClick))
        stateLabel.addGestureRecognizer(tap)
    }
    
    open override func placeSubviews() {
        super.placeSubviews()
        
        if stateLabel.constraints.count != 0{ return }
        
        stateLabel.frame = bounds
    }
    
    open override func setState(_ refreshState: WBRefresh.State) {
        if refreshState == state { return }
        
        super.setState(refreshState)
        
        if refreshingTitleHidden && state == .refreshing {
            stateLabel.text = nil
        }else{
            stateLabel.text = stateTitles[state]
        }
    }
    
    // MARK: - Private 
    @objc private func stateLabelClick() -> Void {
        if state == .default {
            beginRefreshing()
        }
    }
}
