//
//  ViewExtension.swift
//  HSDashedLine
//
//  Created by zwb on 17/2/7.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif


#if os(iOS) || os(tvOS)
    public typealias WBView = UIView
#else
    public typealias WBView = NSView
#endif

// MARK: - 控件的各种属性

public extension WBView {
    
    /// 控件属性的链式响应
    public var ve: WBViewExtension{
        set{}
        get{
            return WBViewExtension(view: self)
        }
    }
}

/// 控件属性的计算
public struct WBViewExtension {
    
    public let ve: WBView
    
    /// init
    ///
    /// - Parameter view: 控件
    public init(view:WBView) {
        ve = view
    }
}

// MARK: - 计算控件属性
public extension WBViewExtension {
    
    /// 控件x坐标
    internal var x:CGFloat {
        set{
            var rect = ve.frame
            rect.origin.x = newValue
            ve.frame = rect
        }
        get{
            return ve.frame.origin.x
        }
    }
    
    /// 控件y坐标
    internal var y:CGFloat{
        set{
            var rect = ve.frame
            rect.origin.y = newValue
            ve.frame = rect
        }
        get{
            return ve.frame.origin.y
        }
    }
    
    /// 控件宽度
    internal var width:CGFloat{
        set{
            var rect = ve.frame
            rect.size.width = newValue
            ve.frame = rect
        }
        get{
            return ve.frame.size.width
        }
    }
    
    /// 控件高度
    internal var height:CGFloat{
        set{
            var rect = ve.frame
            rect.size.height = newValue
            ve.frame = rect
        }
        get{
            return ve.frame.size.height
        }
    }
    
    /// 控件的size
    internal var size:CGSize {
        set{
            var rect = ve.frame
            rect.size = newValue
            ve.frame = rect
        }
        get{
            return ve.frame.size
        }
    }
    
    /// 控件中心点
    internal var center:CGPoint{
        set{
            var w_center = ve.center
            w_center = newValue
            ve.center = w_center
        }
        get{
            return ve.center
        }
    }
    
    /// 控件中心点x坐标
    internal var center_x:CGFloat{
        set{
            var w_center = ve.center
            w_center.x = newValue
            ve.center = w_center
        }
        get{
            return ve.center.x
        }
    }
    
    /// 控件中心点y坐标
    internal var center_y:CGFloat{
        set{
            var w_center = ve.center
            w_center.y = newValue
            ve.center = w_center
        }
        get{
            return ve.center.y
        }
    }
    
    /// 控件顶部距离父视图距离
    internal var top:CGFloat{
        set{
            var rect = ve.frame
            rect.origin.y = newValue
            ve.frame = rect
        }
        get{
            return y
        }
    }
    
    /// 控件底部距离父视图距离
    internal var bottom:CGFloat{
        set{
            var rect = ve.frame
            rect.origin.y = newValue - height
            ve.frame = rect
        }
        get{
            return y + height
        }
    }
    
    /// 控件左部距离父视图距离
    internal var left:CGFloat{
        set{
            var rect = ve.frame
            rect.origin.x = newValue
            ve.frame = rect
        }
        get{
            return x
        }
    }
    
    /// 控件右部距离父视图距离
    internal var right:CGFloat{
        set{
            var rect = ve.frame
            rect.origin.x = newValue - width
            ve.frame = rect
        }
        get{
            return x + width
        }
    }
    
    /// 控件的第一响应视图
    public var firstResponder: UIView{
        if ve.isFirstResponder{
            return ve
        }
        for view in ve.subviews{
            return view.ve.firstResponder
        }
        return UIView()
    }
}
