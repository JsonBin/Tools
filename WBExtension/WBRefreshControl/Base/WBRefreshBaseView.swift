//
//  WBRefreshBaseView.swift
//  WBExtension
//
//  Created by zwb on 17/3/9.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

/// 刷新控件的父类
open class RefreshView: UIView {
    
    /// 正在刷新的回调
    open var refreshingClosure: WBRefresh.ComponentClosure.refreshing?
    
    /// 开始刷新后的回调
    open var beginRefreshingCompletionClosure: WBRefresh.ComponentClosure.begin?
    
    /// 结束刷新的回调
    open var endRefreshingCompletionClosure: WBRefresh.ComponentClosure.end?
    
    /// 是否正在刷新
    open var isRefreshing: Bool { return state == .refreshing || state == .willRefresh }
    
    /// 刷新的状态
    open var state: WBRefresh.State! { didSet{ setState(oldValue) }}
    
    /// 记录scrollView开始的inset
    open var _scrollViewOriginalInset: UIEdgeInsets = .zero
    /// 父控件
    open var _scrollView: UIScrollView!
    
    /// 下拉拖拽的百分比
    open var pullingPercent: CGFloat! { didSet{ setPullPercent(pullingPercent) }}
    
    /// 根据拖拽比例饿自动切换透明度
    open var automaticallyChangeAlpha:Bool = true { didSet{ setAutomaticallyAlpha(automaticallyChangeAlpha) }}
    
    /// 监听的内部手势
    private var pan: UIPanGestureRecognizer?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        state = .default
        
        prepare()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        state = .default
        
        prepare()
    }
    
    // MARK: - 外部调用 (此处为父类)
    
    /// 初始化设置
    open func prepare() -> Void{
        // 设置基本属性
        autoresizingMask = .flexibleWidth
        backgroundColor = .clear
    }
    
    /// 设置子控件frame
    open func placeSubviews() -> Void{}
    /// scrollview的contentOffset改变调用
    ///
    /// - Parameter change: 改变的值字典
    open func scrollViewContentOffsetDidChange(_ change:WBRefresh.Dictionary?) -> Void {}
    /// scrollview的contentSize改变调用
    ///
    /// - Parameter change: 改变的值字典
    open func scrollViewContentSizeDidChange(_ change:WBRefresh.Dictionary?) -> Void {}
    /// scrollview的拖拽状态发生改变调用
    ///
    /// - Parameter change: 改变的值字典
    open func scrollViewPanStateDidChange(_ change:WBRefresh.Dictionary?) -> Void {}
    
    /// 触发回调 (子类调用实现)
    open func executeRefreshingCallBack() -> Void{
        DispatchQueue.main.async {
            if let refreshingBlock = self.refreshingClosure {
                refreshingBlock()
            }
            if let beginRefreshBlock = self.beginRefreshingCompletionClosure {
                beginRefreshBlock()
            }
        }
    }
    
    // MARK: - 公共方法
    
    /// 进入刷新状态
    ///
    /// - Parameter completionClosure: 刷新后的回调
    open func beginRefreshing(withCompletionClosure completionClosure:WBRefresh.ComponentClosure.begin? = nil){
        
        beginRefreshingCompletionClosure = completionClosure
        
        UIView.animate(withDuration: WBRefresh.Animation.fast.rawValue) {
            self.alpha = 1.0
        }
        pullingPercent = 1.0
        // 只要刷新，完全显示
        if window != nil {

            state = .refreshing
        }else{
            // 预防正在刷新中时，调用本方法使得header inset回置失败
            if state != .refreshing {

                state = .refreshing
                // 刷新(预防从另一个控制器回到这个控制器时，重新刷新一下)
                setNeedsDisplay()
            }
        }
    }
    
    /// 结束刷新
    ///
    /// - Parameter completionClosure: 结束刷新的回调
    open func endRefreshing(withCompletionClosure completionClosure:WBRefresh.ComponentClosure.end? = nil) {
        
        endRefreshingCompletionClosure = completionClosure
        
        state = .default
    }
    
    // MARK: - 重写父类方法
    
    open override func layoutSubviews() {
        placeSubviews()
        super.layoutSubviews()
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        // 如果不是scrollview，返回
        if newSuperview != nil &&
            !newSuperview!.isKind(of: UIScrollView.classForCoder()) { return }
        
        // 移除原父控件监听
        removeObservers()
        
        if newSuperview != nil{
            ve.width = newSuperview!.ve.width
            ve.x = 0
            
            // 记录scrollview
            _scrollView = newSuperview as? UIScrollView
            // 设置垂直弹簧效果
            _scrollView.alwaysBounceVertical = true
            // 记录最开始的contenInset
            _scrollViewOriginalInset = _scrollView.contentInset
            
            // 添加监听
            addObservers()
        }
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if state == .willRefresh {
            // 预防view还没显示出来时调用beginRefreshing
            state = .refreshing
        }
    }
    
    // MARK: - Private
    
    // MARK: - KVO
    private func addObservers() -> Void{
        let options:NSKeyValueObservingOptions = [.new, .old]
        _scrollView.addObserver(self, forKeyPath: WBRefresh.KeyPath.contentOffset.rawValue, options: options, context: nil)
        _scrollView.addObserver(self, forKeyPath: WBRefresh.KeyPath.contentSize.rawValue, options: options, context: nil)
        pan = _scrollView.panGestureRecognizer
        pan?.addObserver(self, forKeyPath: WBRefresh.KeyPath.panState.rawValue, options: options, context: nil)
    }
    
    private func removeObservers() -> Void{
        superview?.removeObserver(self, forKeyPath: WBRefresh.KeyPath.contentOffset.rawValue)
        superview?.removeObserver(self, forKeyPath: WBRefresh.KeyPath.contentSize.rawValue)
        pan?.removeObserver(self, forKeyPath: WBRefresh.KeyPath.panState.rawValue)
        pan = nil
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // 不可点击，直接返回
        if !isUserInteractionEnabled { return }
        // 一变化需处理
        if keyPath == WBRefresh.KeyPath.contentSize.rawValue{
            scrollViewContentSizeDidChange(change)
        }
        // 不可见，不处理
        if isHidden { return }
        if keyPath == WBRefresh.KeyPath.contentOffset.rawValue{
            scrollViewContentOffsetDidChange(change)
        }else if keyPath == WBRefresh.KeyPath.panState.rawValue{
            scrollViewPanStateDidChange(change)
        }
    }
    
    // MARK: - setter
    
    /// 设置刷新状态
    ///
    /// - Parameter state: 刷新状态
    open func setState(_ refreshState:WBRefresh.State) -> Void{
        // 加入主队列等setState:方法调用完毕、设置完文字后再去布局子控件
        DispatchQueue.main.async {
            self.setNeedsLayout()
        }
    }
    
    /// 设置alpha
    ///
    /// - Parameter percent: alpha
    open func setPullPercent(_ percent:CGFloat) -> Void{
        if isRefreshing { return }
        if automaticallyChangeAlpha {
            alpha = pullingPercent
        }
    }
    
    /// 设置是否自动变化alpha
    ///
    /// - Parameter automatically: true or false
    private func setAutomaticallyAlpha(_ automatically:Bool) -> Void{
        if isRefreshing { return }
        if automaticallyChangeAlpha {
            alpha = pullingPercent
        }else{
            alpha = 1.0
        }
    }
}

// MARK: - 生成一个label
public extension UILabel {
    
    public static var wb_label: UILabel {
        let label = self.init()
        label.font = WBRefresh.Label.font
        label.textColor = WBRefresh.Label.textColor
        label.autoresizingMask = .flexibleWidth
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }
    
    public var wb_textWidth: CGFloat {
        var stringWidth: CGFloat = 0
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
        let attr = [NSFontAttributeName: font]
        guard let wbText = text else {
            return stringWidth
        }
        if wbText.characters.count > 0 {
            stringWidth = wbText.boundingRect(with: size,
                                              options: [.usesLineFragmentOrigin],
                                              attributes: attr,
                                              context: nil).size.width
        }
        return stringWidth
    }
}
