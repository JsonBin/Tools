//
//  RunTimeExtension.swift
//  WBExtension
//
//  Created by zwb on 17/3/1.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

public typealias WBObject = NSObject

public extension WBObject {
    
    @available(iOS 8.0, *)
    /// 链式函数
    public var run: WBRunTime {
        return WBRunTime(self)
    }
    
    /// 动态添加属性
    ///
    /// - Parameters:
    ///   - name: 需要添加的属性名
    ///   - proClass: 需要添加的属性类别
    internal func addProperty(_ name:String, proClass:AnyClass) {
        
        propertyName = name
        let type = objc_property_attribute_t(name: "T", value: "\\\(NSStringFromClass(proClass).utf8)\\")
        let ownership = objc_property_attribute_t(name: "&", value: "N")
        let backingivar = objc_property_attribute_t(name: "V", value: name)
        let attrs = [type, ownership, backingivar]
        // 添加属性
        if class_addProperty(classForCoder, name, attrs, 3) {
            // get
            let method = class_getInstanceMethod(classForCoder, #selector(get))
            class_addMethod(classForCoder, NSSelectorFromString(name), method_getImplementation(method), method_getTypeEncoding(method))
            
            // set
            let methodSet = class_getInstanceMethod(classForCoder, #selector(set))
            let proName = name.substring(to: name.index(name.startIndex, offsetBy: 1)).uppercased()
            let proNameSet = name.substring(from: name.index(name.startIndex, offsetBy: 1))
            let setString = "set" + proName + proNameSet + ":"
            class_addMethod(classForCoder, NSSelectorFromString(setString), method_getImplementation(methodSet), method_getTypeEncoding(methodSet))
        }
        
    }
    
    /// get方法
    ///
    /// - Returns: getter
    @objc private func get() -> Any {
        let keyPoint = UnsafeRawPointer(bitPattern: propertyName.hashValue)
        return objc_getAssociatedObject(classForCoder, keyPoint)
    }
    
    /// set方法
    ///
    /// - Parameter newValue: 新值
    @objc private func set(_ newValue: Any!) {
        let keyPoint = UnsafeRawPointer(bitPattern: propertyName.hashValue)
        objc_setAssociatedObject(classForCoder, keyPoint, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
private var propertyName:String = ""

public protocol WBObjectDSL {
}

extension WBObjectDSL {
}

public struct WBRunTime : WBObjectDSL {
    
    /// 需要使用的对象
    internal let objc : WBObject
    
    /// init
    ///
    /// - Parameter object: 使用的对象
    internal init(_ object:WBObject) {
        objc = object
    }
    
    // MARK: - runtime 属性相关的方法
    
    /// 动态添加属性
    ///
    /// - Parameters:
    ///   - name: 属性的名字
    ///   - proClass: 属性的类型
    public func addProperty(_ name:String, propertyClass proClass: AnyClass) {
        if containProperty(name) { return }
        
        objc.addProperty(name, proClass: proClass)
    }
    
    /// 是否包含属性
    ///
    /// - Parameter proper: 属性名
    /// - Returns: true or false
    @discardableResult public func containProperty(_ proper:String) -> Bool {
        return allProperties.contains(proper)
    }
    
    /// 获取属性列表
    public var allProperties : [String] {
        return getAllProperties()
    }
    
    /// 赋值
    ///
    /// - Parameters:
    ///   - value: 保存的值
    ///   - key: 保存的key
    public func safeSetValue(_ value:Any?, forKey key:String) {
        guard let value = value else { return }
        addProperty(key, propertyClass: (value as AnyObject).classForCoder)
        objc.setValue(value, forKey: key)
    }
    /// 取值
    ///
    /// - Parameter key: 需要取值的key
    /// - Returns: 结果对象
    @discardableResult public func safeValue(forKey key:String) -> Any? {
        if containProperty(key) {
            propertyName = key
            return objc.value(forKey: key)
        }
        return nil
    }
    
    // MARK: - model和json相关的方法
    
    /// 根据字典设置模型
    ///
    /// - Parameter dictionary: 需要转化的字典
    /// - Returns: 转化的结果 model 类
    @discardableResult public func modelWithDictionary(_ dictionary:NSDictionary) -> Any? {
        let model = objc.classForCoder.alloc() as! WBObject
        let keys = dictionary.allKeys as! [String]
        for key in keys {
            model.run.safeSetValue(dictionary.value(forKey: key), forKey: key)
        }
        return model
    }
    
    /// 根据model生成字典
    public var dictionary: NSDictionary {
        let dictionary = NSMutableDictionary()
        let keys = allProperties
        for key in keys {
            guard let value = safeValue(forKey: key) else{
                dictionary.setValue(NSNull(), forKey: key)
                continue
            }
            dictionary.setValue(value, forKey: key)
        }
        return dictionary.copy() as! NSDictionary
    }
    
    /// 根据json生成model
    ///
    /// - Parameter data: 需要转化的data
    /// - Returns: 转化的结果 model 类
    public func modelWithJson(_ data:Data) -> Any? {
        do {
            let dic = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            return modelWithDictionary(dic as! NSDictionary)
        } catch {
            return nil
        }
    }
    
    /// 根据model生成json
    public var json: Data? {
        let dic = dictionary
        do {
            let data = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            return data
        } catch {
            return nil
        }
    }
    
    /// 优化description的方法
    public var description: String {
        let allkeys = allProperties
        // 分割线
        let starStr = "\n**************************\n"
        // 类名.地址
        var descriptionStr = "\n\n<\(objc.classForCoder):\(objc)>"
        descriptionStr.append(starStr)
        for key in allkeys {
            guard let value = safeValue(forKey: key) else{
                descriptionStr.append("\n\(key) = nil")
                continue
            }
            descriptionStr.append("\n\(key) = \(value)")
        }
        descriptionStr.append(starStr)
        return descriptionStr
    }
    
}

extension WBRunTime {
    
    /// 获取属性列表
    ///
    /// - Returns: 属性名字列表
    public func getAllProperties() -> [String] {
        var outCount:UInt32 = 0
        guard let propertyList = class_copyPropertyList(objc.classForCoder, &outCount) else { return [] }
        var arrays = [String]()
        // 遍历
        for index in 0...Int(outCount) {
            if let property = propertyList[index] , let cName = property_getName(property),  let peropertyName = String(validatingUTF8: cName) {
                arrays.append(peropertyName)
            }
        }
        free(propertyList)
        return arrays
    }
}
