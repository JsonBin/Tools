//
//  WBRefreshFooter.swift
//  WBExtension
//
//  Created by zwb on 17/3/13.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

/// 上拉加载的父类
open class WBRefreshFooter : RefreshView {
    
    /// 忽略多少scrollview的contentinset的bottom
    open var ignoredScrollViewContentInsetBottom: CGFloat = 0
    
    /// 自动根据有无数据来显示和隐藏(有数据显示，无数据隐藏, 默认false)
    open var automaticallHidden: Bool = false
    
    /// 初始化init
    ///
    /// - Parameter refreshClosure: 刷新closure
    public convenience init(refreshing refreshClosure:WBRefresh.ComponentClosure.refreshing? = nil) {
        self.init()
        
        refreshingClosure = refreshClosure
    }
    
    // MARK: - 重写父类
    open override func prepare() {
        super.prepare()
        // 设置高度
        ve.height = WBRefresh.Float.footer.rawValue
        // 设置默认不隐藏
        automaticallHidden = false
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if let _ = newSuperview {
            // 监听scrollview数据变化
            if _scrollView.isKind(of: UITableView.classForCoder()) || _scrollView.isKind(of: UICollectionView.classForCoder()) {
                _scrollView.se.reloadDataClosure = { [unowned self] count in
                    if self.automaticallHidden {
                        self.isHidden = count == 0
                    }
                }
            }
        }
    }
    
    // MARK: - 回调方法
    
    /// 重置没有更多数据(取消没有更多数据的状态)
    open func resetNoMoreData() -> Void {
        state = .default
    }
    
    /// 提示没有更多数据
    open func endNoMoreData() -> Void {
        state = .noMoreData
    }
}
