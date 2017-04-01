//
//  WBRefreshNormalHeader.swift
//  WBExtension
//
//  Created by zwb on 17/3/10.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation


open class WBRefreshNormalHeader: WBRefreshStateHeader {
    
    /// 下拉加载的图片
    open var arrowView: UIImageView! {
        if let view = _arrowView {
            return view
        }
        _arrowView = UIImageView(image: Bundle.wb_arrowImage)
        addSubview(_arrowView)
        return _arrowView
    }
    private var _arrowView: UIImageView!
    
    /// 菊花的样式
    open var activityIndicatorViewStyle: UIActivityIndicatorViewStyle? {
        didSet{
            loadingView = nil
            setNeedsLayout()
        }
    }
    
    /// 菊花
    private lazy var loadingView: UIActivityIndicatorView! = {
       let loadView = UIActivityIndicatorView(activityIndicatorStyle:self.activityIndicatorViewStyle!)
        loadView.hidesWhenStopped = true
        self.addSubview(loadView)
        return loadView
    }()
    
    // MARK: -  重写父类
    open override func prepare() {
        super.prepare()
        
        activityIndicatorViewStyle = .gray
        
    }
    
    open override func placeSubviews() {
        super.placeSubviews()
        
        // 箭头中心点
        var arrowCenterX = ve.width * 0.5
        if !stateLabel.isHidden {
            let stateWidth = stateLabel.wb_textWidth
            var timeWidth:CGFloat = 0.0
            if !lastUpdatedTimeLabel.isHidden {
                timeWidth = lastUpdatedTimeLabel.wb_textWidth
            }
            let textWidth = max(stateWidth, timeWidth)
            arrowCenterX -= textWidth / 2 + labelLeftInset
        }
        let arrowCenterY = ve.height * 0.5
        let arrowCenter = CGPoint(x: arrowCenterX, y: arrowCenterY)
        
        // 箭头
        if arrowView.constraints.count == 0 {
            arrowView.ve.size = arrowView.image!.size
            arrowView.center = arrowCenter
        }
        
        // 圈圈
        if loadingView.constraints.count == 0 {
            loadingView.center = arrowCenter
        }
        
        arrowView.tintColor = stateLabel.textColor
    }
    
    open override func setState(_ refreshState: WBRefresh.State) {
        if refreshState == state { return }
        
        super.setState(refreshState)
        
        // 根据状态做事
        if state == .default {
            if refreshState == .refreshing {
                arrowView.transform = .identity
                UIView.animate(withDuration: WBRefresh.Animation.slow.rawValue, animations: { 
                    self.loadingView.alpha = 0.0
                }, completion: { (finished) in
                    // 如果执行完动画发现不是default状态，直接返回，进入其他状态
                    if self.state != .default { return }
                    
                    self.loadingView.alpha = 1.0
                    self.loadingView.stopAnimating()
                    self.arrowView.isHidden = false
                })
            }else{
                self.loadingView.stopAnimating()
                self.arrowView.isHidden = false
                UIView.animate(withDuration: WBRefresh.Animation.fast.rawValue, animations: { 
                    self.arrowView.transform = .identity
                })
            }
        }else if state == .pulling {
            self.loadingView.stopAnimating()
            self.arrowView.isHidden = false
            UIView.animate(withDuration: WBRefresh.Animation.fast.rawValue, animations: { 
                self.arrowView.transform = CGAffineTransform(rotationAngle: 0.0000001 - CGFloat(M_PI))
            })
        }else if state == .refreshing {
            // 防止 refreshing -> default 动画完毕没有执行
            self.loadingView.alpha = 1.0
            self.loadingView.startAnimating()
            self.arrowView.isHidden = true
        }
    }
}
