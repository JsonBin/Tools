//
//  ControlExtension.swift
//  HSDashedLine
//
//  Created by zwb on 17/2/6.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit


// MARK: - 控制点击时间间隔

extension UIControl {
    
    private struct ControlKey {
        public static let eventInterval = UnsafeRawPointer(bitPattern: "UIControl_acceptEventInterval".hashValue)
        public static let eventTime = UnsafeRawPointer(bitPattern: "UIControl_acceptEventTime".hashValue)
    }
    
    internal var customEventInterval:TimeInterval!{
        set{
            objc_setAssociatedObject(self, ControlKey.eventInterval, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            guard let time = objc_getAssociatedObject(self, ControlKey.eventInterval) else {
                return 1.0
            }
            return time as! TimeInterval
        }
    }
    
    fileprivate var customEventTime:TimeInterval!{
        set{
            objc_setAssociatedObject(self, ControlKey.eventTime, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            guard let time = objc_getAssociatedObject(self, ControlKey.eventTime) else {
                return 1.0
            }
            return time as! TimeInterval
        }
    }
    
    override open class func initialize() {
        let systemMethod = class_getInstanceMethod(classForCoder(), #selector(sendAction(_:to:for:)))
        let sysSEL = #selector(sendAction(_:to:for:))
        
        let customMethod = class_getInstanceMethod(classForCoder(), #selector(customSendAction(_:to:for:)))
        let customSEL = #selector(customSendAction(_:to:for:))
        
        let didAddMethod = class_addMethod(classForCoder(), sysSEL, method_getImplementation(customMethod), method_getTypeEncoding(customMethod))
        
        if didAddMethod {
            class_replaceMethod(classForCoder(), customSEL, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod))
        }else{
            method_exchangeImplementations(systemMethod, customMethod)
        }
    }
    
    
    @objc private func customSendAction(_ action:Selector, to target:Any?, for event:UIEvent?){
        
        /* 设置统一的时间间隔
         如果设置了统一的时间间隔，会影响UISwitch，如果不想影响UISwitch可以将UIControl
         设置为Extension UIButton
        if customEventInterval< = 0{
            customEventInterval = 2.0
        }*/
        
        let needSendAction = (Date().timeIntervalSince1970-customEventTime) >= customEventInterval
        
        if customEventInterval>0{
            customEventTime = Date().timeIntervalSince1970
        }
        
        if needSendAction {
            customSendAction(action, to: target, for: event)
        }
    }
}
