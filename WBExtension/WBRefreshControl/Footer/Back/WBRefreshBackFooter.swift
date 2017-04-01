//
//  WBRefreshBackFooter.swift
//  WBExtension
//
//  Created by zwb on 17/3/14.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

/// 刷新完自动回弹的父类
open class WBRefreshBackFooter : WBRefreshFooter {
    
    private var lastRefreshCount: Int = 0
    private var lastBottomDelta: CGFloat = 0
    
    // MARK: - 重写父类
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        scrollViewContentSizeDidChange(nil)
    }
    
    open override func scrollViewContentOffsetDidChange(_ change: WBRefresh.Dictionary?) {
        super.scrollViewContentOffsetDidChange(change)
        
        // 正在刷新，直接返回
        if state == .refreshing { return }
        
        _scrollViewOriginalInset = _scrollView.contentInset
        
        // 当前的contentOffset
        let currentOffsetY = _scrollView.se.offsetY
        // footer刚好出现的offsetY
        let showOffsetY = showOffset
        // 向下滚动，直接返回
        if currentOffsetY <= showOffsetY { return }
        
        let pullingPer = (currentOffsetY - showOffsetY) / ve.height
        // 如果全部加载，仅设置pullingPercent，然后返回
        if state == .noMoreData {
            pullingPercent = pullingPer
            return
        }
        // 正在拖拽
        if _scrollView.isDragging {
            pullingPercent = pullingPer
            // 普通 和 即将刷新 的临界点
            let defaultPullingOffsetY = showOffsetY + ve.height
            
            if state == .default && currentOffsetY >  defaultPullingOffsetY {
                // 转为即将刷新
                state = .pulling
            }else if state == .pulling && currentOffsetY <= defaultPullingOffsetY {
                // 转为普通
                state = .default
            }
        }else if state == .pulling { // 即将刷新和手松开时
            // 开始刷新
            beginRefreshing()
        }else if pullingPer < 1 {
            pullingPercent = pullingPer
        }
    }
    
    open override func scrollViewContentSizeDidChange(_ change: WBRefresh.Dictionary?) {
        super.scrollViewContentSizeDidChange(change)
        
        // 内容高度
        let contentHeight = _scrollView.se.contentHeight + ignoredScrollViewContentInsetBottom
        // 表格高度
        let scrollviewHeight = _scrollView.ve.height - _scrollViewOriginalInset.top - _scrollViewOriginalInset.bottom + ignoredScrollViewContentInsetBottom
        // 设置位置
        ve.y = max(contentHeight, scrollviewHeight)
    }
    
    open override func setState(_ refreshState: WBRefresh.State) {
        if refreshState == state { return }
        
        super.setState(refreshState)
        
        // 根据状态设置属性
        if state == .noMoreData || state == .default {
            // 刷新完毕
            if refreshState == .refreshing {
                UIView.animate(withDuration: WBRefresh.Animation.slow.rawValue, animations: { 
                    self._scrollView.se.insetBottom -= self.lastBottomDelta
                    
                    // 自动设置透明度
                    if self.automaticallyChangeAlpha {
                        self.alpha = 0.0
                    }
                }, completion: { (finished) in
                    self.pullingPercent = 0.0
                    if let endClosure = self.endRefreshingCompletionClosure {
                        endClosure()
                    }
                })
            }
            let deltaH = heightForContentBreakView
            // 刚刷新完毕
            if refreshState == .refreshing && deltaH > 0 && _scrollView.se.totalDataCount != lastRefreshCount {
                _scrollView.se.offsetY = _scrollView.se.offsetY
            }
        }else if state == .refreshing {
            // 记录刷新前数据
            lastRefreshCount = _scrollView.se.totalDataCount
            
            UIView.animate(withDuration: WBRefresh.Animation.fast.rawValue, animations: { 
                var bottom = self.ve.height + self._scrollViewOriginalInset.bottom
                let deltaH = self.heightForContentBreakView
                if deltaH < 0 { bottom -= deltaH } // 内容高度小于view高度
                self.lastBottomDelta = bottom -  self._scrollView.se.insetBottom
                self._scrollView.se.insetBottom = bottom
                self._scrollView.se.offsetY = self.showOffset + self.ve.height
            }, completion: { (finished) in
                self.executeRefreshingCallBack()
            })
        }
    }
    
    open override func endRefreshing(withCompletionClosure completionClosure: WBRefresh.ComponentClosure.end?) {
        DispatchQueue.main.async {
            self.state = .default
        }
    }
    
    open override func endNoMoreData() {
        DispatchQueue.main.async {
            self.state = .noMoreData
        }
    }
    
    // MARK: -  Private 
    
    /// 获取footer刚好看见的contentOffset.y
    private var showOffset: CGFloat {
        let deltaHeight = heightForContentBreakView
        if deltaHeight > 0 {
            return deltaHeight - _scrollViewOriginalInset.top
        }
        return -_scrollViewOriginalInset.top
    }
    
    /// 获取scrollview的内容高度
    private var heightForContentBreakView: CGFloat {
        let h = _scrollView.ve.height - _scrollViewOriginalInset.bottom - _scrollViewOriginalInset.top
        return _scrollView.contentSize.height - h
    }
    
}
