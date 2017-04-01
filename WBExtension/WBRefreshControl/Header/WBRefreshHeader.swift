//
//  WBRefreshHeader.swift
//  WBExtension
//
//  Created by zwb on 17/3/9.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation


/// 下拉刷新控件的父类
open class WBRefreshHeader: RefreshView {
    
    /// 存储上一次下拉刷新成功的时间key
    open var lastUpdatedTimeKey: String! {
        didSet{ setLastUpdateKey(lastUpdatedTimeKey) }
    }
    
    /// 上一次下拉刷新成功的时间
    open var lastUpdatedTime: Date! {
        return UserDefaults.standard.object(forKey: lastUpdatedTimeKey!) as? Date!
    }
    
    /// 忽略多少scrollview的contentInset的top
    open var ignoredScrollViewContentInsetTop: CGFloat = 0
    
    /// 私有成员属性
    private var insetTopDelta: CGFloat = 0
    
    /// 初始化 init
    ///
    /// - Parameter refreshClosure: 刷新closure
    public convenience init(refreshing refreshClosure:WBRefresh.ComponentClosure.refreshing? = nil) {
        self.init()
        
        refreshingClosure = refreshClosure
    }
    
    // MARK: - 暴露出设置key的方法
    
    /// 重新设置key值
    ///
    /// - Parameter lastKey: key值
    open func setLastUpdateKey(_ lastKey:String) -> Void {}
    
    // MARK: - 重写父类的方法
    open override func prepare() {
        super.prepare()
        
        // 设置key
        lastUpdatedTimeKey = WBRefresh.HeaderText.lastUpdateTimeKey.rawValue
        // 高度
        ve.height = WBRefresh.Float.header.rawValue
    }
    
    open override func placeSubviews() {
        super.placeSubviews()
        
        // 设置y值(当自己的高度发生改变，重新调整y,放到layoutSubviews中设置)
        ve.y = -ve.height - ignoredScrollViewContentInsetTop
    }
    
    open override func scrollViewContentOffsetDidChange(_ change: WBRefresh.Dictionary?) {
        super.scrollViewContentOffsetDidChange(change)
        
        // 根据刷新状态来设置
        if state == .refreshing {
            if window == nil { return }
            // sectionHeader停留解决办法
            var insetT = -_scrollView.se.offsetY > _scrollViewOriginalInset.top ? -_scrollView.se.offsetY : _scrollViewOriginalInset.top
            
            insetT = insetT > ve.height + _scrollViewOriginalInset.top ? ve.height + _scrollViewOriginalInset.top : insetT
            _scrollView?.se.insetTop = insetT
            insetTopDelta = _scrollViewOriginalInset.top - insetT
            return
        }
        
        // 跳转到下一个控制器时，contentInset可能会变
        _scrollViewOriginalInset = _scrollView.contentInset
        
        // 当前的contentOffset
        let offsetY = _scrollView.se.offsetY
        // 头部控件刚好出现的offsetY
        let showOffsetY = -_scrollViewOriginalInset.top
        
        // 向上滚动，直接返回
        if offsetY > showOffsetY { return }
        
        // 普通 和 即将刷新的临界点
        let defaultpullingOffsetY = showOffsetY - ve.height
        let pullingPer = (showOffsetY - offsetY) / ve.height
        
        if _scrollView.isDragging { // 正在拖拽
            pullingPercent = pullingPer
            if state == .default && offsetY < defaultpullingOffsetY {
                // 转为即将刷新状态
                state = .pulling
            }else if state == .pulling && offsetY >= defaultpullingOffsetY{
                // 转为普通状态
                state = .default
            }/*else if state == .pulling && offsetY < -100 {
                // 下拉超过100,自动开始刷新
                state = .refreshing
            }*/
        }else if state == .pulling { // 即将刷新 和 手松开
            // 开始刷新
            beginRefreshing()
        }else if pullingPer < 1 {
            pullingPercent = pullingPer
        }
    }
    
    open override func setState(_ refreshState: WBRefresh.State) {
        if refreshState == state { return }
        
        super.setState(refreshState)
        // 根据刷新状态做事
        if state == .default {
            if refreshState != .refreshing { return }
            
            // 保存刷新时间
            UserDefaults.standard.set(Date(), forKey: lastUpdatedTimeKey!)
            UserDefaults.standard.synchronize()
            
            // 恢复inset和offset
            UIView.animate(withDuration: WBRefresh.Animation.slow.rawValue, animations: {
                self._scrollView.se.insetTop += self.insetTopDelta
                
                // 自动调整透明度
                if self.automaticallyChangeAlpha {
                    self.alpha = 0.0
                }
            }, completion: { (finished) in
                self.pullingPercent = 0.0
                if let endBlock = self.endRefreshingCompletionClosure{
                    endBlock()
                }
            })
        }else if state == .refreshing {
            DispatchQueue.main.async {
                UIView.animate(withDuration: WBRefresh.Animation.fast.rawValue, animations: {
                    let top = self._scrollViewOriginalInset.top + self.ve.height
                    // 增加滚动区域top
                    self._scrollView.se.insetTop = top
                    // 设置滚动位置
                    self._scrollView.setContentOffset(CGPoint(x: 0, y: -top), animated: false)
                }, completion: { (finished) in
                    self.executeRefreshingCallBack()
                })
            }
        }
    }
    
    open override func endRefreshing(withCompletionClosure completionClosure: WBRefresh.ComponentClosure.end? = nil) {
        DispatchQueue.main.async {
            self.state = .default
        }
    }
}
