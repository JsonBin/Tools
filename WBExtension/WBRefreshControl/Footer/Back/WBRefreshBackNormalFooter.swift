//
//  WBRefreshBackNormalFooter.swift
//  WBExtension
//
//  Created by zwb on 17/3/14.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

/// 正常结构的加载footer
open class WBRefreshBackNormalFooter : WBRefreshBackStateFooter {
    
    /// 上拉图片
    open var arrowView: UIImageView {
        if let view = _arrowView {
            return view
        }
        _arrowView = UIImageView(image: Bundle.wb_arrowImage)
        addSubview(_arrowView)
        return _arrowView
    }
    private var _arrowView: UIImageView!
    
    /// 菊花的样式
    open var activityIndicatorViewStyle: UIActivityIndicatorViewStyle! {
        didSet{
            loadingView = nil
            setNeedsLayout()
        }
    }
    
    /// 菊花
    private lazy var loadingView: UIActivityIndicatorView! = {
       let view = UIActivityIndicatorView(activityIndicatorStyle: self.activityIndicatorViewStyle)
        view.hidesWhenStopped = true
        self.addSubview(view)
        return view
    }()
    
    // MARK：- 重写父类
    
    open override func prepare() {
        super.prepare()
        
        activityIndicatorViewStyle = .gray
    }
    
    open override func placeSubviews() {
        super.placeSubviews()
        
        // 箭头的中心
        var arrowCenterX = ve.width * 0.5
        if !stateLabel.isHidden {
            arrowCenterX -= labelLeftInset + stateLabel.wb_textWidth * 0.5
        }
        let arrowCenterY = ve.height * 0.5
        let arrowCenter = CGPoint(x: arrowCenterX, y: arrowCenterY)
        
        // 箭头
        if arrowView.constraints.count == 0 {
            arrowView.ve.size = arrowView.image!.size
            arrowView.center = arrowCenter
        }
        
        // 菊花
        if loadingView.constraints.count == 0 {
            loadingView.center = arrowCenter
        }
        arrowView.tintColor = stateLabel.textColor
    }
    
    open override func setState(_ refreshState: WBRefresh.State) {
        if refreshState ==  state { return }
        
        super.setState(refreshState)
        
        // 根据状态处理
        if state == .default {
            if refreshState == .refreshing {
                arrowView.transform = CGAffineTransform(rotationAngle: 0.0000001 - CGFloat(M_PI))
                UIView.animate(withDuration: WBRefresh.Animation.slow.rawValue, animations: { 
                    self.loadingView.alpha = 0.0
                }, completion: { (finished) in
                    self.loadingView.alpha = 1.0
                    self.loadingView.stopAnimating()
                    self.arrowView.isHidden = false
                })
            }else {
                arrowView.isHidden = false
                loadingView.stopAnimating()
                UIView.animate(withDuration: WBRefresh.Animation.fast.rawValue, animations: { 
                    self.arrowView.transform = CGAffineTransform(rotationAngle: 0.0000001 - CGFloat(M_PI))
                })
            }
        }else if state == .pulling {
            arrowView.isHidden = false
            loadingView.stopAnimating()
            UIView.animate(withDuration: WBRefresh.Animation.fast.rawValue, animations: { 
                self.arrowView.transform = .identity
            })
        }else if state == .refreshing {
            arrowView.isHidden = true
            loadingView.startAnimating()
        }else if state == .noMoreData {
            arrowView.isHidden = true
            loadingView.stopAnimating()
        }
    }
    
}
