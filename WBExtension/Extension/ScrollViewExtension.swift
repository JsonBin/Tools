//
//  ScrollViewExtension.swift
//  WBExtension
//
//  Created by zwb on 17/2/17.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit

// MARK: - 继承于UIScrollView的视图，下拉时放大动画的效果，常用于UITableView

/*
 使用方法如下所示:
 
 let label = UILabel()
 label.frame = CGRect(x: 0, y: 0, width: s_width, height: 50)
 label.text = "jklajdklfjakldjakljdflkadjflkadjfa"
 label.backgroundColor = UIColor.black
 label.textColor = UIColor.white
 
 tableView.addCover(withImage: UIImage(named: "bg_photo")!, withView: label)
 /*tableView.tableHeaderView = tableView.coverView*/
 tableView.tableHeaderView = UIView(frame: CGRect(x: 0,
 y: 0,
 width: s_width,
 height: UIScrollView.WBCoverKey.wbdefaultHeight + 50))
 
 */


// MARK: - ScrollView 添加下拉放大动画
public extension UIScrollView {
    
    
    /// 私有存储key
    public struct WBCoverKey {
        public static let wbcoverView = "wb_uiscollview_coverView"
        public static let wbcoverViewPoint = UnsafeRawPointer(bitPattern: wbcoverView.hashValue)
        public static var wbdefaultHeight:CGFloat = 200  // 视图默认高度
    }
    
    /// 添加之后的视图
    public var coverView:WBCoverView!{
        set{
            willChangeValue(forKey: WBCoverKey.wbcoverView)
            objc_setAssociatedObject(self, WBCoverKey.wbcoverViewPoint, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            didChangeValue(forKey: WBCoverKey.wbcoverView)
        }
        get{
            guard let view = objc_getAssociatedObject(self, WBCoverKey.wbcoverViewPoint) else {
                return nil
            }
            return view as! WBCoverView
        }
    }
    
    
    /// 添加的方法，可更改高度，也可以在顶部添加自定义视图
    ///
    /// - Parameters:
    ///   - image: 将要添加的图片
    ///   - height: 设置的图片高度
    ///   - view: 顶部要显示的视图
    public func addCover(withImage image:UIImage, imageHeight height:CGFloat? = nil, withView view:UIView? = nil) {
        
        if let height = height {
            WBCoverKey.wbdefaultHeight = height
        }
        
        let coverAboveView = WBCoverView(CGRect(x: 0,
                                                y: 0,
                                                width: frame.size.width,
                                                height: WBCoverKey.wbdefaultHeight),
                                         topView:view)
        
        coverAboveView.backgroundColor = UIColor.clear
        coverAboveView.image = image
        coverAboveView.scrollView = self
        
        addSubview(coverAboveView)
        if let view = view { addSubview(view) }
        coverView = coverAboveView
    }
    
    /// 用于deinit时移除kvo
    public func removeCoverView() {
        
        coverView.removeFromSuperview()
        coverView = nil
    }
    
}

// MARK: -  用于生成下拉可放大的ImageView视图

public class WBCoverView : UIImageView {
    
    /// scrollview
    public var scrollView:UIScrollView! {
        didSet{
            scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        }
    }
    
    /// 顶部view
    private var topView:UIView?
    
    /// 默认高度
    private var defaultHeight:CGFloat!
    
    
    /// init 初始化方法
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - view: 顶部view
    public convenience init(_ frame:CGRect, topView view:UIView? = nil) {
        
        self.init(frame: frame)
        
        contentMode  =  .scaleAspectFill
        clipsToBounds = true
        topView = view
        defaultHeight = frame.size.height
    }
    
    /// 重写移除视图
    public override func removeFromSuperview() {
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
        topView?.removeFromSuperview()
        super.removeFromSuperview()
    }
    
    public override func layoutSubviews() {
        
        super.layoutSubviews()
        if scrollView.contentOffset.y<0{
            
            let offsetY = (scrollView.contentOffset.y + scrollView.contentInset.top) * -1
            
            if let topView = topView {
                topView.frame = CGRect(x: topView.frame.origin.x,
                                       y: offsetY * -1,
                                       width: topView.frame.size.width,
                                       height: topView.frame.size.height)
                
                frame = CGRect(x: frame.origin.x,
                               y: offsetY * -1 + topView.frame.size.height,
                               width: frame.size.width,
                               height: defaultHeight + offsetY)
            }
            else{
                
                frame = CGRect(x: frame.origin.x,
                               y: offsetY * -1,
                               width: frame.size.width,
                               height: defaultHeight + offsetY)
            }
        }else{
            if let topView = topView {
                topView.frame = CGRect(x: topView.frame.origin.x,
                                       y: 0,
                                       width: topView.frame.size.width,
                                       height: topView.frame.size.height)
                
                frame = CGRect(x: frame.origin.x,
                               y: topView.frame.size.height,
                               width: frame.size.width,
                               height: defaultHeight)
            }
            else{
                
                frame = CGRect(x: frame.origin.x,
                               y: 0,
                               width: frame.size.width,
                               height: defaultHeight)
            }
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        setNeedsLayout()
    }
    
}
