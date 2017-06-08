//
//  WBWebImageCache.swift
//  WBExtension
//
//  Created by zwb on 17/3/2.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

// MARK: -

/// 缓存策略
///
/// - noCache: 不缓存
/// - memory: 内存缓存
/// - disk: 磁盘缓存
public enum WBWebImageCachePolicy : UInt8 {
    case noCache
    case memory
    case disk
}

// MARK: -

/// 缓存数据类型
///
/// - undefined: 未定义
/// - data: data数据
/// - image: image数据
public enum WBWebImageCacheType : UInt8 {
    case undefined
    case data
    case image
}

public class WBWebImageCache {
    
    public static let `default` = WBWebImageCache()
    
    // 缓存策略
    public var cachePolicys : [WBWebImageCachePolicy]
    
    // 缓存数据类型
    public var cacheType : WBWebImageCacheType
    
    // 缓存过期时间，默认7天
    public var expirateTime : UInt32
    
    // 是否加密缓存
    public var useSecureKey: Bool
    
    /// 已缓存的空间大小
    public var cacheSize: CGFloat {
        return calculateSize()
    }
    
    // 缓存空间
    public var cacheSpace: String = "WbImage.default.cacheSpace"
    
    private var memeryCache:  NSCache<AnyObject, AnyObject>
    
    private var semaphore : DispatchSemaphore
    
    private var fileManager : FileManager
    
    private var asyncDispatchQueue:DispatchQueue

    
    /// init cache
    ///
    /// - Parameters:
    ///   - cache: NSCache
    ///   - time: cache time
    ///   - secureKey: use md5 to cache
    ///   - policyType: cache policy
    ///   - type: cache type
    public init(_ cache:NSCache<AnyObject, AnyObject> = WBWebImageCache.defaultCache(), expirate time:UInt32 = UInt32(WBWebImageCacheDefaultExpirateTime), use secureKey:Bool = true, policy policyType:[WBWebImageCachePolicy] = [.disk], cacheType type:WBWebImageCacheType = .data) {
        memeryCache = cache
        expirateTime = time
        useSecureKey = secureKey
        cachePolicys = policyType
        cacheType = type
        semaphore = DispatchSemaphore(value: 1)
        fileManager = FileManager.default
        
        asyncDispatchQueue = {
            let name = String(format: "com.wbwebimage.imagecache-%08x%08x", arc4random(),arc4random())
            return DispatchQueue(label: name, attributes: .concurrent)
        }()
        
        let path = sandBoxPath(cacheSpace)
        if !fileManager.fileExists(atPath: path) {
            try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    
    /// set default NSCache
    ///
    /// - Returns: Default NSCache
    public static func defaultCache() -> NSCache<AnyObject, AnyObject> {
        let memeryCache = NSCache<AnyObject, AnyObject>()
        memeryCache.totalCostLimit = WBWebImageCacheDefaultCost
        memeryCache.countLimit = 20
        return memeryCache
    }
    
    // MARK: - Public
    
    /// 缓存数据
    ///
    /// - Parameters:
    ///   - objc: 缓存对象
    ///   - key: 缓存对应的key
    public func cacheObjc(_ objc:Any, forKey key:String) {
        let url = key
        let md5 = useSecureKey ? md5String(key) : key
        if cachePolicys.contains(.disk) {
            writeFileWithKey(objc, url: url, key: md5, semaphore: semaphore, fileManager: fileManager, cacheSpace: cacheSpace)
        }
        if cachePolicys.contains(.memory) {
            memeryCache.setObject(objc as AnyObject, forKey: md5 as AnyObject, cost: costForObject(objc))
        }
    }
    
    
    /// 读取缓存数据
    ///
    /// - Parameter key: 缓存对应的key
    /// - Returns: 缓存对象
    public func objcCache(for key:String) -> Any? {
        let md5 = useSecureKey ? md5String(key) : key
        var objc : Any?
        if let  obj = memeryCache.object(forKey: md5 as AnyObject) {
            return obj
        }else{
            precondition(cacheType != .undefined, "you must set a cacheType but not undefined")
            readFile(with: md5, cacheType: cacheType, semaphore: semaphore, cacheSpace: cacheSpace, completion: { [unowned self] (object) in
                objc = object
                
                // 缓存到内存中
                if let image = object, self.cachePolicys.contains(.memory) {
                    self.memeryCache.setObject(image as AnyObject, forKey: md5 as AnyObject, cost: costForObject(image))
                }
            })
        }
        return objc
    }
    
    
    /// 移除缓存
    ///
    /// - Parameter key: 缓存对应的key
    public func remoCache(for key:String) {
        let md5 = useSecureKey ? md5String(key) : key
        memeryCache.removeObject(forKey: md5 as AnyObject)
        let path = sandBoxPath(cacheSpace)+"/\(md5)"
        try? fileManager.removeItem(atPath: path)
    }
    
    
    /// 移除超时的缓存
    public func removeExpirateCache() {
        asyncDispatchQueue.async {
            let dir = self.fileManager.enumerator(atPath: sandBoxPath(self.cacheSpace))!
            let timeStamp = Date().timeIntervalSince1970
            var path = dir.nextObject()
            while path != nil {
                let newPath = sandBoxPath(self.cacheSpace)+"/\(path!)"
                do{
                    let attrs = try self.fileManager.attributesOfItem(atPath: newPath)
                    if let dateCreate = attrs[.modificationDate] as? Date {
                        if timeStamp - dateCreate.timeIntervalSince1970 > Double(self.expirateTime) {
                            try self.fileManager.removeItem(atPath: newPath)
                        }
                    }
                    path = dir.nextObject()
                }catch{}
            }
        }
    }
    
    /// 删除缓存
    public func removeCache() -> Void{
        memeryCache.removeAllObjects()
        calculateSize(true)
    }
    
    // MARK: - Private
    
    /// 将文件通过异步的方式写到磁盘中
    ///
    /// - Parameters:
    ///   - objc: 缓存对象
    ///   - url: 获取数据的url
    ///   - key: md5加密或未加密的文件名
    ///   - semaphore: 异步信号
    ///   - fileManager: 文件管理器
    ///   - cacheSpace: 缓存的文件目录
    private func writeFileWithKey(_ objc:Any, url:String, key:String, semaphore:DispatchSemaphore, fileManager:FileManager, cacheSpace:String) {
        asyncDispatchQueue.async {
            _=semaphore.wait(timeout: .distantFuture)
            let path = sandBoxPath(cacheSpace)+"/\(key)"
            do{
                if fileManager.fileExists(atPath: path){
                    try fileManager.removeItem(atPath: path)
                }
                let fileURL = URL(fileURLWithPath: path)
                try self.objectToData(objc).write(to: fileURL)
                DispatchQueue.main_safe {
                    // 缓存成功
                    NotificationCenter.default.post(name: WBWebImageCacheCompleteNotification, object: nil, userInfo: ["url":url])
                }
            }catch{
                fatalError("write image or data to disk failed!")
            }
            
            semaphore.signal()
        }
    }
    
    
    /// 将文件中缓存目录中通过同步方式读取出来
    ///
    /// - Parameters:
    ///   - key: 缓存文件名
    ///   - cacheType: 缓存类型
    ///   - semaphore: 异步等待信号
    ///   - cacheSpace: 缓存文件目录
    ///   - completion: 读取文件成功后的回调
    private func readFile(with key:String, cacheType:WBWebImageCacheType, semaphore:DispatchSemaphore, cacheSpace:String, completion:((_ image:Any?) -> Void)?) {
        asyncDispatchQueue.sync{
            _=semaphore.wait(timeout: .distantFuture)
            
            defer{
                semaphore.signal()
            }
            
            let path = sandBoxPath(cacheSpace)+"/\(key)"
            let url = URL(fileURLWithPath: path)
            do{
                let data = try Data(contentsOf: url)
                guard let complete = completion else {
                    return
                }
                complete(dataToObjc(data, cacheType: cacheType))
            }catch{
                WHLogs("read data from disk failed!")
                if let complete = completion {
                    complete(nil)
                }
            }
        }
    }
    
    
    /// 将文件对象转换为Data类型
    ///
    /// - Parameter object: 数据对象
    /// - Returns: NSData
    private func objectToData(_ object:Any) -> Data {
        var data : Data!
        if object is Data {
            data = object as! Data
        }else if object is UIImage {
            data = UIImageJPEGRepresentation(object as! UIImage, 1.0)
        }
        return data
    }
    
    
    /// 将Data装换为对象类型
    ///
    /// - Parameters:
    ///   - data: 将要转换的数据
    ///   - cacheType: 要转换类型
    /// - Returns: 转换的结果
    private func dataToObjc(_ data:Data, cacheType:WBWebImageCacheType) -> Any? {
        switch cacheType {
        case .data:
            return data
        case .image:
            return UIImage(data: data)
        default:
            return nil
        }
    }
    
    /// 计算缓存目录下的文件大小或删除缓存
    ///
    /// - Returns: 缓存大小
    @discardableResult private func calculateSize(_ remove:Bool = false) -> CGFloat{
        let cachePath = sandBoxPath(cacheSpace)
        if !fileManager.fileExists(atPath: cachePath) { return 0 }
        
        guard let filePaths = fileManager.subpaths(atPath: cachePath) else {
            return 0
        }
        var filesize:CGFloat = 0
        for file in filePaths.enumerated(){
            let fileAbsolutePath = (cachePath as NSString).appendingPathComponent(file.element)
            if !remove {
                filesize += fileSizeAtPath(fileAbsolutePath)
            }else{
                if fileManager.fileExists(atPath: fileAbsolutePath) {
                    do{
                        try fileManager.removeItem(atPath: fileAbsolutePath)
                    }catch{}
                }
            }
        }
        return filesize
    }
    
    /// 计算单个文件的大小
    ///
    /// - Parameter path: 文件路径
    /// - Returns: 文件大小
    private func fileSizeAtPath(_ path:String) -> CGFloat{
        if fileManager.fileExists(atPath: path){
            do {
                let dictionary = try fileManager.attributesOfItem(atPath: path)
                if let size = dictionary[.size] as? NSNumber {
                    return CGFloat(size)
                }
                return 0
            } catch  {
                return 0
            }
        }
        return 0
    }
}

// MARK: -

/// 获取缓存文件对应的路径
///
/// - Parameter cacheSpace: 缓存目录
/// - Returns: 缓存对应的路径
public func sandBoxPath(_ cacheSpace:String) -> String{
    return NSHomeDirectory()+"/Documents/WBWebImage.cache/"+cacheSpace
}


/// md5加密字符
///
/// - Parameter string: 将要加密的字符
/// - Returns: 加密后的字符
public func md5String(_ string:String) -> String {
    let str = string.cString(using: String.Encoding.utf8)
    let strLen = CUnsignedInt(string.lengthOfBytes(using: String.Encoding.utf8))
    let digestLen = Int(CC_MD5_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
    CC_MD5(str!, strLen, result)
    let hash = NSMutableString()
    for i in 0 ..< digestLen {
        hash.appendFormat("%02x", result[i])
    }
    result.deinitialize()
    return String(format: hash as String)
}


/// 计算数据的容量
///
/// - Parameter objc: 将要计算的数据
/// - Returns: 数据的大小
public func costForObject(_ objc:Any) -> Int {
    var cost = 0
    if objc is Data {
        cost = (objc as! Data).count
    }else if objc is UIImage {
        let image = objc as! UIImage
        cost = Int(image.size.width * image.size.height * image.scale * image.scale)
    }
    return cost
}
