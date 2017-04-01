//
//  WBRefreshAutoFooter.swift
//  WBExtension
//
//  Created by zwb on 17/3/13.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

/// 常规刷新完的footer父类
open class WBRefreshAutoFooter :  WBRefreshFooter {
    
    /// 是否自动刷新. Default true
    open var automaticallyRefresh: Bool = true
    
    /// 当footer出现多少开始自动刷新. Default 1.0
    open var triggerAutomaticallyRefreshPercent: CGFloat! = 1.0
    
    
    // MARK: - 重写父类
    open override func prepare() {
        super.prepare()
        // 设置默认完全显示时才刷新
        triggerAutomaticallyRefreshPercent = 1.0
        // 设置自动刷新
        automaticallyRefresh = true
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if let _ = newSuperview {
            if !isHidden {
                _scrollView.se.insetBottom += ve.height
            }
            // 设置位置
            ve.y = _scrollView.se.contentHeight
        }else{  // 被移除
            if !isHidden {
                _scrollView.se.insetBottom -= ve.height
            }
        }
    }
    
    open override func scrollViewContentSizeDidChange(_ change: WBRefresh.Dictionary?) {
        super.scrollViewContentSizeDidChange(change)
        // 设置位置
        ve.y = _scrollView.se.contentHeight
    }
    
    open override func scrollViewContentOffsetDidChange(_ change: WBRefresh.Dictionary?) {
        super.scrollViewContentOffsetDidChange(change)
        
        if state != .default || !automaticallyRefresh || ve.y == 0 { return }
        
        if _scrollView.se.insetTop + _scrollView.se.contentHeight > _scrollView.ve.height {
            // 内容超出屏幕
            //(用_scrollView!.se.contentHeight 替换掉 ve.height 合理)
            if _scrollView.se.offsetY >= (_scrollView.se.contentHeight - _scrollView.ve.height + ve.height * triggerAutomaticallyRefreshPercent + _scrollView.se.insetBottom - ve.height) {
                
                let old = change![.oldKey] as! CGPoint
                let new = change![.newKey] as! CGPoint
                if new.y <= old.y { return }
                
                // 当footer完全出现开始刷新
                beginRefreshing()
            }
        }
    }
    
    open override func scrollViewPanStateDidChange(_ change: WBRefresh.Dictionary?) {
        super.scrollViewPanStateDidChange(change)
        
        if state != .default { return }
        
        if _scrollView.panGestureRecognizer.state == .ended {
            // 手松开
            if _scrollView.se.insetTop + _scrollView.se.contentHeight <= _scrollView.ve.height {
                // 不够一个屏幕
                if _scrollView.se.offsetY >= -_scrollView.se.insetTop {
                    // 向上拉
                    beginRefreshing()
                }
            }else{
                // 超出一个屏幕
                if _scrollView.se.offsetY >= _scrollView.se.contentHeight + _scrollView.se.insetBottom - _scrollView.ve.height {
                    beginRefreshing()
                }
            }
        }
    }
    
    open override func setState(_ refreshState: WBRefresh.State) {
        if refreshState == state { return }
        
        super.setState(refreshState)
        
        if state == .refreshing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { 
                self.executeRefreshingCallBack()
            })
        }else if state == .noMoreData || state == .default {
            if refreshState == .refreshing {
                if let endClosure = endRefreshingCompletionClosure {
                    endClosure()
                }
            }
        }
    }
    
    /// 重写控件隐藏的属性
    open override var isHidden: Bool { didSet{ setHidden(oldValue) }}
    
    // MARK: -  Private 
    
    /// 设置hidden
    ///
    /// - Parameter hidden: true or false
    private func setHidden(_ hidden:Bool) -> Void {
        
        super.isHidden = isHidden
        
        if !hidden && isHidden {
            state = .default
            _scrollView.se.insetBottom -= ve.height
        }else if hidden && !isHidden {
            _scrollView.se.insetBottom += ve.height
            // 设置位置
            ve.y = _scrollView.se.contentHeight
        }
    }
}
