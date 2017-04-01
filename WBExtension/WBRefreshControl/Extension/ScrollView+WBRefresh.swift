//
//  ScrollView+WBRefresh.swift
//  WBExtension
//
//  Created by zwb on 17/3/10.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation


// MARK: - 设置下拉刷新控件 - header

public extension WBScrollViewExtension {
    
    /// 下拉刷新控件
    var header: WBRefreshHeader! {
        set{
            if header != newValue {
                // 移除旧的，添加新的
                if let header = header {
                    header.removeFromSuperview()
                }
                se.insertSubview(newValue, at: 0)
                
                // 存储新的
                se.willChangeValue(forKey: "header")
                objc_setAssociatedObject(se, WBRefreshHeaderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                se.didChangeValue(forKey: "header")
            }
        }
        get{
            guard let header = objc_getAssociatedObject(se, WBRefreshHeaderKey) else {
                return nil
            }
            return header as! WBRefreshHeader
        }
    }
    
    
}
private let WBRefreshHeaderKey = UnsafeRawPointer(bitPattern: "WBRefreshHeaderKey".hashValue)

// MARK: - 设置上拉加载控件 - footer

public extension WBScrollViewExtension {
    
    var footer: WBRefreshFooter! {
        set{
            // 移除旧的，添加新的
            if let footer = footer {
                footer.removeFromSuperview()
            }
            se.insertSubview(newValue, at: 0)
            
            se.willChangeValue(forKey: "footer")
            objc_setAssociatedObject(se, WBRefreshFooterKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            se.didChangeValue(forKey: "footer")
        }
        get{
            guard let footer = objc_getAssociatedObject(se, WBRefreshFooterKey) else {
                return nil
            }
            return footer as! WBRefreshFooter
        }
    }
}
private let WBRefreshFooterKey = UnsafeRawPointer(bitPattern: "WBRefreshFooterKey".hashValue)

// MARK: - tableView 和 collectionView属性
public extension WBScrollViewExtension {
    
    var totalDataCount: Int {
        var totalCount = 0
        if se.isKind(of: UITableView.classForCoder()){
            let tableView = se as! UITableView
            for section in 0..<tableView.numberOfSections {
                totalCount += tableView.numberOfRows(inSection: section)
            }
        }else if se.isKind(of: UICollectionView.classForCoder()){
            let collectionView = se as! UICollectionView
            for section in 0..<collectionView.numberOfSections {
                totalCount += collectionView.numberOfItems(inSection: section)
            }
        }
        return totalCount
    }
    
    var reloadDataClosure: ((_ count:Int) -> Void)! {
        set{
            se.willChangeValue(forKey: "reloadDataClosure") // kvo
            if let v = newValue {
                objc_setAssociatedObject(se, WBRefreshReloadDataClosureKey, v, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            }
            se.didChangeValue(forKey: "reloadDataClosure")
        }
        get{
            guard let closure = objc_getAssociatedObject(se, WBRefreshReloadDataClosureKey) else {
                return nil
            }
            return closure as! (_ count:Int) -> Void
        }
    }
}
private let WBRefreshReloadDataClosureKey = UnsafeRawPointer(bitPattern: "WBRefreshReloadDataClosureKey".hashValue)


// MARK: - tableView 刷新回调方法
extension UITableView {
    
    override open class func initialize() {
        
        methodSwizzlingWithOriginal(#selector(reloadData), bySwizzled: #selector(wb_refreshData))
    }
    
    open func wb_refreshData() -> Void {
        
        wb_refreshData()
        
        if let closure = se.reloadDataClosure {
            closure(se.totalDataCount)
        }
    }
}

// MARK: - collectionView 刷新回调方法
extension UICollectionView {
    
    override open class func initialize() {
        methodSwizzlingWithOriginal(#selector(reloadData), bySwizzled: #selector(wb_refreshData))
    }
    
    open func wb_refreshData() -> Void{
        wb_refreshData()
        
        if let closure = se.reloadDataClosure {
            closure(se.totalDataCount)
        }
    }
}


// MARK: - swizzling method

public extension NSObject {
    
    /// 交换方法
    ///
    /// - Parameters:
    ///   - originalSelector: 原方法
    ///   - swizzledSelector: 将要替换的方法
    public static func methodSwizzlingWithOriginal(_ originalSelector:Selector, bySwizzled swizzledSelector:Selector) -> Void{
        let originalMethod=class_getInstanceMethod(classForCoder(), originalSelector)
        let swizzledMethod=class_getInstanceMethod(classForCoder(), swizzledSelector)
        let didAddMethod=class_addMethod(classForCoder(), originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        if didAddMethod{
            class_replaceMethod(classForCoder(), swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        }else{
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}
