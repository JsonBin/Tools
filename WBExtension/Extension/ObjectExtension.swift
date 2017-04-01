//
//  ObjectExtension.swift
//  HSDashedLine
//
//  Created by zwb on 17/2/6.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit

// MARK: - 私有实现KVO的真实target类，每一个target对应一个keyPath和监听该keyPath的所有block,
//         当其KVO方法调用时,需要回调所有的block
public class WBBlockTarget: NSObject {
    
    // 存放所有的block
    private var _kvoBlockSet:[kvoBlock]!
    private var _notificationBlockSet:[notificationBlock]!
    
    public typealias kvoBlock = (_ obj:Any?, _ oldValue:Any?, _ newValue:Any?)->Void
    public typealias notificationBlock = (_ notificaton:Notification)->Void
    
    override init() {
        super.init()
        
        _kvoBlockSet = []
        _notificationBlockSet = []
    }
    
    // 添加一个KVO block
    public func wb_addBlock(_ block:@escaping kvoBlock) {
        _kvoBlockSet.append(block)
    }
    
    // 添加一个Notification block
    public func wb_addNotificationBlock(_ block:@escaping notificationBlock) {
        _notificationBlockSet.append(block)
    }
    
    public func wb_doNotification(_ notification:Notification) {
        if _notificationBlockSet.count == 0 {
            return
        }
        for block in _notificationBlockSet{
            block(notification)
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if _kvoBlockSet.count == 0 {
            return
        }
        let prior = change?[NSKeyValueChangeKey.notificationIsPriorKey] as! Bool
        // 只接受值改变时的消息
        if prior {
            return
        }
        let changeKind = (change?[NSKeyValueChangeKey.kindKey] as! NSString).integerValue
        if changeKind != NSKeyValueChange.setting.hashValue {
            return
        }
        var oldVal = change?[NSKeyValueChangeKey.oldKey]
        if oldVal is NSNull {
            oldVal = nil
        }
        var newVal = change?[NSKeyValueChangeKey.newKey]
        if newVal is NSNull {
            newVal = nil
        }
        // 执行该target下的所有block
        for block in _kvoBlockSet{
            block(object, oldVal, newVal)
        }
    }
}

public extension NSObject {
    
    private struct WBObjectKey {
        static let kvoSemaphoreKey = "WBKVOSemaphoreKey"
        static let notificationSemaphoreKey = "WBNotificationSemaphoreKey"
        static let kvoBlockKey = UnsafeRawPointer(bitPattern: "WBKVOBlockKey".hashValue)
        static let notificationBlockKey = UnsafeRawPointer(bitPattern: "WBNotificationBlockKey".hashValue)
        static let deinitHasSwizzledKey = UnsafeRawPointer(bitPattern: "WBDeinitHasSwizzledKey".hashValue)
    }
    
    // MARK: - KVO
    
    /// 通过block方式注册一个kvo,通过该方式注册kvo无需手动移除，会在被监听对象销毁的
    /// 时候自动移除
    public func wb_addObserverBlockForKeyPath(_ keyPath:String?, block andBlock:WBBlockTarget.kvoBlock? ) {
        guard let keyPath = keyPath else {
            WB_Log("注册KVO时，keyPath不能为nil!")
            return
        }
        guard let andBlock = andBlock else {
            WB_Log("注册KVO时，block不能为nil")
            return
        }
        let kvoSemaphore = _wb_getSemaphoreWithKey(WBObjectKey.kvoSemaphoreKey)
        _ = kvoSemaphore.wait(timeout: .distantFuture)
        // 取出存有所有KVOTarget的字典
        var allTargets = objc_getAssociatedObject(self, WBObjectKey.kvoBlockKey) as! NSMutableDictionary?
        if allTargets == nil{
            // 没有创建
            allTargets = NSMutableDictionary()
            // 绑定在该对象中
            objc_setAssociatedObject(self, WBObjectKey.kvoBlockKey, allTargets!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        // 获取对应keyPath中的所有target
        var targetForKeyPath = allTargets?.object(forKey: keyPath) as! WBBlockTarget?
        if targetForKeyPath == nil{
            // 没有则创建
            targetForKeyPath = WBBlockTarget()
            // 保存
            allTargets?[keyPath] = targetForKeyPath!
            // 如果为第一次，则注册对keyPath的KVO监听
            addObserver(targetForKeyPath!, forKeyPath: keyPath, options: [.new,.old], context: nil)
        }
        targetForKeyPath?.wb_addBlock(andBlock)
        // 对第一次注册KVO的类进行deinit方法调剂
        _wb_swizzleDeinit()
        kvoSemaphore.signal()
    }
    
    /// 提前移除指定keyPath下的通过block注册的kvo(需要提前注销kvo时才需要)
    public func wb_removeObserverBlockForKeyPath(_ keyPath:String?){
        guard let keyPath = keyPath else {
            WB_Log("移除KVO时，keyPath不能为nil!")
            return
        }
        guard let allTargets = objc_getAssociatedObject(self, WBObjectKey.kvoBlockKey) as? NSMutableDictionary else {
            WB_Log("还未通过wb_addObserverBlockForKeyPath(_:block:)添加KVO方法!")
            return
        }
        guard let target = allTargets.object(forKey: keyPath) as? WBBlockTarget else {
            WB_Log("当前的\(keyPath)还未注册KVO方法!")
            return
        }
        let kvoSemaphore = _wb_getSemaphoreWithKey(WBObjectKey.kvoSemaphoreKey)
        _ = kvoSemaphore.wait(timeout: .distantFuture)
        removeObserver(target, forKeyPath: keyPath)
        allTargets.removeObject(forKey: keyPath)
        kvoSemaphore.signal()
    }
    
    /// 提前移除所有通过block注册的kvo
    public func wb_removeAllObserverBlocks() {
        guard let allTargets = objc_getAssociatedObject(self, WBObjectKey.kvoBlockKey) as? NSMutableDictionary else {
            WB_Log("还未通过wb_addObserverBlockForKeyPath(_:block:)添加KVO方法!")
            return
        }
        let kvoSemaphore = _wb_getSemaphoreWithKey(WBObjectKey.kvoSemaphoreKey)
        _ = kvoSemaphore.wait(timeout: .distantFuture)
        allTargets.enumerateKeysAndObjects({ (key, target, stop) in
            removeObserver(target as! WBBlockTarget, forKeyPath: key as! String)
        })
        allTargets.removeAllObjects()
        kvoSemaphore.signal()
    }
    
    // MARK: - Notification
    
    /// 通过block方式注册通知，通过该方式注册的通知无需手动移除，会自动移除
    public func wb_addNotificationForName(_ name:String?, block andBlock:WBBlockTarget.notificationBlock?) {
        guard let name = name else {
            WB_Log("注册通知时,通知的名字不能为nil!")
            return
        }
        guard let andBlock = andBlock else {
            WB_Log("注册通知时,通知的回调不能为nil!")
            return
        }
        let notificationSemaphore = _wb_getSemaphoreWithKey(WBObjectKey.notificationSemaphoreKey)
        _ = notificationSemaphore.wait(timeout: .distantFuture)
        // 取出存有所有NotificationTarget的字典
        var allTargets = objc_getAssociatedObject(self, WBObjectKey.notificationBlockKey) as? NSMutableDictionary
        if allTargets == nil{
            // 没有创建
            allTargets = NSMutableDictionary()
            // 绑定在该对象中
            objc_setAssociatedObject(self, WBObjectKey.notificationBlockKey, allTargets!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        // 获取对应name中的所有target
        var target = allTargets?.object(forKey: name) as! WBBlockTarget?
        if target == nil{
            // 没有创建
            target = WBBlockTarget()
            // 保存
            allTargets?[name] = target!
            // 如果为第一次，则注册名字为name的通知
            NotificationCenter.default.addObserver(self, selector: #selector(WBBlockTarget.wb_doNotification(_:)), name: Notification.Name.init(rawValue: name), object: nil)
        }
        target?.wb_addNotificationBlock(andBlock)
        // 对第一次注册通知的类进行deinit方法调剂
        _wb_swizzleDeinit()
        notificationSemaphore.signal()
    }
    
    /// 提前移除一个为name的通知
    public func wb_removeNotificatonForName(_ name:String?) {
        guard let name = name else {
            WB_Log("移除通知时,name不能为nil!")
            return
        }
        guard let allTargets = objc_getAssociatedObject(self, WBObjectKey.notificationBlockKey) as? NSMutableDictionary else {
            WB_Log("还未通过wb_addNotificationForName(_:block:)注册通知方法!")
            return
        }
        guard let target = allTargets.object(forKey: name) as? WBBlockTarget else {
            WB_Log("当前的\(name)还未注册通知方法!")
            return
        }
        let notificationSemaphore = _wb_getSemaphoreWithKey(WBObjectKey.notificationSemaphoreKey)
        _ = notificationSemaphore.wait(timeout: .distantFuture)
        NotificationCenter.default.removeObserver(target)
        allTargets.removeObject(forKey: name)
        notificationSemaphore.signal()
    }
    
    /// 提前移除所有的通知
    public func wb_removeAllNotification() {
        guard let allTargets = objc_getAssociatedObject(self, WBObjectKey.notificationBlockKey) as? NSMutableDictionary else {
            WB_Log("还未通过wb_addNotificationForName(_:block:)注册通知方法!")
            return
        }
        let notificationSemaphore = _wb_getSemaphoreWithKey(WBObjectKey.notificationSemaphoreKey)
        _ = notificationSemaphore.wait(timeout: .distantFuture)
        allTargets.enumerateKeysAndObjects({ (key, target, stop) in
            NotificationCenter.default.removeObserver(target as! WBBlockTarget)
        })
        allTargets.removeAllObjects()
        notificationSemaphore.signal()
    }
    
    /// 发送一个通知
    public func wb_postNotificatonWithName(_ name:String?, userInfo dictionary:[AnyHashable : Any]?) {
        guard let name = name else {
            WB_Log("发送通知时,通知的名字不能为nil!")
            return
        }
        NotificationCenter.default.post(name: Notification.Name.init(rawValue: name), object: nil, userInfo: dictionary)
    }
    
    // 调剂deinit方法，由于无法直接使用runtime的swizzle方法对deinit方法进行调剂
    private typealias deinitBlock = (_:Any,_:Selector)->Void
    private dynamic func _wb_swizzleDeinit() {
        // 给每个类绑定一个值来判断deinit方法是否被调剂了，如果调剂过则无需再次调剂
        let swizzled = objc_getAssociatedObject(self, WBObjectKey.deinitHasSwizzledKey) as! Bool
        // 如果调剂过，返回
        if swizzled { return }
        // 开始调剂
        objc_sync_enter(classForCoder)
        // 获取原有的deinit方法
        let deinitSelector = sel_registerName(UnsafePointer(bitPattern: "deinit".hashValue))
        // 初始化一个函数指针用于保存原有的deinit方法
        var originalDeinit:deinitBlock? = nil
        // 通过block实现自己的deinit方法
        let newDeinit = { [unowned self] in
            // 移除所有的kvo
            self.wb_removeAllObserverBlocks()
            // 移除所有的通知
            self.wb_removeAllNotification()
            // 根据原有的deinit方法是否存在进行判断
            if originalDeinit == nil {
                // 如果不存在，说明本类没有实现deinit方法，则需要向父类发送deinit消息(objc_msgSendSuper)
                // 构造objc_msgSendSuper所需要的参数，.receiver为方法的实际调用者，即为类本身，.super_class指向其父类
                let classString = NSStringFromClass(self.classForCoder)
                let classPoint = UnsafeRawPointer(bitPattern: classString.hashValue)
                let receiver = Unmanaged<AnyObject>.fromOpaque(classPoint!)
                var superInfo = objc_super(receiver: receiver, super_class: class_getSuperclass(self.classForCoder))
                // 构建objc_msgSendSuper函数
                // 向super发送deinit消息
                _msgSend(&superInfo, deinitSelector!)
                
            }else{
                // 如果存在，表面该类实现了deinit方法，直接调用即可
                // 调用原有的deinit方法
                originalDeinit!(self, deinitSelector!)
            }
        }()
        // 根据block构建新的deinit实现IMP
        let newDeinitIMP = imp_implementationWithBlock(newDeinit)
        // 尝试添加新的deinit方法，如果该类已经复写deinit方法则不能添加成功，反之则能成功
        let type = UnsafePointer<Int8>(bitPattern: "v@:".hashValue)
        if !class_addMethod(classForCoder, deinitSelector!, newDeinitIMP!, type) {
            // 如果没有添加成功则保存原有的deinit方法，用于新的deinit方法中
            let deinitMethod = class_getInstanceMethod(classForCoder, deinitSelector!)
            originalDeinit = imp_getBlock(method_getImplementation(deinitMethod)) as? deinitBlock
            originalDeinit = imp_getBlock(method_setImplementation(deinitMethod, newDeinitIMP)) as? deinitBlock
        }
        // 标记该类已经调剂过了
        objc_setAssociatedObject(classForCoder, WBObjectKey.deinitHasSwizzledKey, true, .OBJC_ASSOCIATION_ASSIGN)
        objc_sync_exit(classForCoder)
    }
    
    private func _wb_getSemaphoreWithKey(_ key:String) -> DispatchSemaphore {
        let keyPoint = UnsafeRawPointer(bitPattern: key.hashValue)
        var semaphore = objc_getAssociatedObject(self, keyPoint)
        if semaphore != nil{
            semaphore = DispatchSemaphore(value: 1)
        }
        return semaphore as! DispatchSemaphore
    }
    
    
    // MARK: - Coding
    
    // 编码(将对象写入文件中)
    public func encode(_ encoder:NSCoder) {
        var outCount:UInt32 = 0
        guard let ivars = class_copyIvarList(classForCoder, &outCount) else { return }
        for index in 0..<Int(outCount){
            guard let ivar = ivars[index] else { continue }
            guard let key = String(utf8String: ivar_getName(ivar)) else { continue }
            encoder.encode(value(forKey: key), forKey: key)
        }
    }
    
    // 解码(从文件中解析对象)
    public func decode(_ decoder:NSCoder) {
        var outCount:UInt32 = 0
        guard let ivars = class_copyIvarList(classForCoder, &outCount) else { return }
        for index in 0..<Int(outCount){
            guard let ivar = ivars[index] else { continue }
            guard let key = String(utf8String: ivar_getName(ivar)) else { continue }
            setValue(decoder.decodeObject(forKey: key), forKey: key)
        }
    }
    
}
