//
//  ScrollView+WBExtension.swift
//  WBExtension
//
//  Created by zwb on 17/3/9.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif


#if os(iOS) || os(tvOS)
    public typealias WBScrollView = UIScrollView
#else
    public typealias WBScrollView = NSScrollView
#endif

// MARK: - 控件的各种属性

public extension WBScrollView {
    
    /// 控件属性的链式响应
    public var se: WBScrollViewExtension{
        set{}
        get{
            return WBScrollViewExtension(view: self)
        }
    }
}

/// 控件属性的计算
public struct WBScrollViewExtension {
    
    public let se: WBScrollView
    
    /// init
    ///
    /// - Parameter view: 控件
    public init(view:WBScrollView) {
        se = view
    }
}

// MARK: - 计算控件属性
public extension WBScrollViewExtension {

    /// scrollview的contentinset顶部
    var insetTop: CGFloat {
        set{
            var inset = se.contentInset
            inset.top = newValue
            se.contentInset = inset
        }
        get{
            return se.contentInset.top
        }
    }
    
    /// scrollview的contentinset底部
    var insetBottom: CGFloat {
        set{
            var inset = se.contentInset
            inset.bottom = newValue
            se.contentInset = inset
        }
        get{
            return se.contentInset.bottom
        }
    }
    
    /// scrollview的conteoninset左部
    var insetLeft: CGFloat {
        set{
            var inset = se.contentInset
            inset.left = newValue
            se.contentInset = inset
        }
        get{
            return se.contentInset.left
        }
    }
    
    /// scrollview的conteoninset右部
    var insetRight: CGFloat{
        set{
            var inset = se.contentInset
            inset.right = newValue
            se.contentInset = inset
        }
        get{
            return se.contentInset.right
        }
    }
    
    /// scrollview的x偏移量
    var offsetX: CGFloat {
        set{
            var offset = se.contentOffset
            offset.x = newValue
            se.contentOffset = offset
        }
        get{
            return se.contentOffset.x
        }
    }
    
    /// scrollview的y偏移量
    var offsetY: CGFloat {
        set{
            var offset = se.contentOffset
            offset.y = newValue
            se.contentOffset = offset
        }
        get{
            return se.contentOffset.y
        }
    }
    
    /// scrollview的contentsize宽度
    var contentWidth: CGFloat {
        set{
            var size = se.contentSize
            size.width = newValue
            se.contentSize = size
        }
        get{
            return se.contentSize.width
        }
    }
    
    /// scrollview的contentsize高度
    var contentHeight: CGFloat {
        set{
            var size = se.contentSize
            size.height = newValue
            se.contentSize = size
        }
        get{
            return se.contentSize.height
        }
    }
}

 
