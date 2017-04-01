//
//  WBRefreshAutoNormalFooter.swift
//  WBExtension
//
//  Created by zwb on 17/3/14.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

/// 正常加载控件
open class WBRefreshAutoNormalFooter : WBRefreshAutoStateFooter {
    
    /// 菊花的样式
    open var activityIndicatorViewStyle: UIActivityIndicatorViewStyle! { didSet { setActivityStyle(activityIndicatorViewStyle) }}
    
    /// 菊花
    private lazy var loadingView: UIActivityIndicatorView! = {
       let view = UIActivityIndicatorView(activityIndicatorStyle: self.activityIndicatorViewStyle)
        view.hidesWhenStopped = true
        self.addSubview(view)
        return view
    }()
    
    // MARK: - 重写父类
    open override func prepare() {
        super.prepare()
        
        activityIndicatorViewStyle = .gray
    }
    
    open override func placeSubviews() {
        super.placeSubviews()
        
        if loadingView.constraints.count != 0 { return }
        
        // 菊花
        var loadingCenterX = ve.width * 0.5
        if !refreshingTitleHidden {
            loadingCenterX -= stateLabel.wb_textWidth * 0.5 + labelLeftInset
        }
        let loadingCenterY = ve.height * 0.5
        loadingView.center = CGPoint(x: loadingCenterX, y: loadingCenterY)
    }
    
    open override func setState(_ refreshState: WBRefresh.State) {
        if refreshState == state { return }
        
        super.setState(refreshState)
        
        if state == .noMoreData || state == .default {
            loadingView.stopAnimating()
        }else if state == .refreshing {
            loadingView.startAnimating()
        }
    }
    
    // MARK: - Private
    private func setActivityStyle(_ style: UIActivityIndicatorViewStyle) -> Void {
        loadingView = nil
        setNeedsLayout()
    }
}
