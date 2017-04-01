//
//  WBWebImageManager.swift
//  WBExtension
//
//  Created by zwb on 17/3/2.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation


/// WebImage管理器
public class WBWebImageManager {
    
    /// 实现单列
    public static let `default` = WBWebImageManager()
    
    /// 事物管理器
    private var operations:[String: WBWebImageOperation]
    
    /// 缓存管理器
    private var cache:WBWebImageCache
    
    /// 网络session
    private let session: URLSession
    
    /// 异步信号
    private let semaphore: DispatchSemaphore
    
    /// 事物管理队列
    private let queue: OperationQueue
    
    /// 最后的一次事物
    private var lastOperation: WBWebImageOperation?
    
    /// 异步线程
    private let asyncQueue: DispatchQueue = {
        let name = String(format: "com.wbwebimage.manager-%08x%08x", arc4random(),arc4random())
        return DispatchQueue(label: name)
    }()
    
    /// 初始化管理器
    public init() {
        
        semaphore = DispatchSemaphore(value: 1)
        cache = WBWebImageCache.default
        cache.cachePolicys = [.disk,.memory]
        cache.removeExpirateCache()
        
        operations = {
            return [:]
        }()
        
        session = {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 15.0
            return URLSession(configuration: config)
        }()
        
        queue = {
            let q = OperationQueue()
            q.maxConcurrentOperationCount = 6
            return q
        }()
        
        DispatchQueue.main_safe {
            NotificationCenter.default.addObserver(self, selector: #selector(self.downloadFinishNotiResponse(_:)), name: WBWebImageDownloadFinishNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.cacheCompleteFinishNotiResponse(_:)), name: WBWebImageCacheCompleteNotification, object: nil)
        }
    }
    
    
    /// 通过URL开始下载图片
    ///
    /// - Parameters:
    ///   - url: 图片URL
    ///   - complete: 完成下载之后的回调
    public func downloadImage(_ url:ImageURLConvertible, completion complete:@escaping WBWebImageCallBack) {
        guard let url = try? url.wbURL().absoluteString else { return }
        asyncQueue.async {
            // 缓存
            if let data = self.cache.objcCache(for: url) {
                if data is Data {
                    if let image = UIImage(data: data as! Data) {
                        DispatchQueue.main_safe {
                            complete(image)
                        }
                    }
                }
                else if data is UIImage {
                    DispatchQueue.main_safe {
                        complete(data as! UIImage)
                    }
                }
            }
            else{ // 无缓存
                _ = self.semaphore.wait(timeout: .distantFuture)
                var operation = self.operations[url] // 取出任务
                if operation == nil {
                    operation = WBWebImageOperation(url, session: self.session)
                    self.operations[url] = operation
                    if self.lastOperation != nil{
                        self.lastOperation?.addDependency(operation!)
                    }
                    self.queue.addOperation(operation!)
                    self.lastOperation = operation
                }
                if !operation!.downloader.downFinish {
                    operation!.downloader.callBacks.append(complete)
                }else{
                    // 缓存读取
                    DispatchQueue.main_safe {
                        complete(operation!.downloader.image!)
                    }
                }
                self.semaphore.signal()
            }
        }
    }
    
    /// 移除进程
    ///
    /// - Parameter url: 图片URL
    public func removeOperation(_ url:ImageURLConvertible) {
        guard let url = try? url.wbURL().absoluteString else {
            return
        }
        let operation = operations[url]
        operation?.cancel()
        operations.removeValue(forKey: url)
    }
    
    /// 下载完成通知
    ///
    /// - Parameter notifiction: 完成通知
    @objc private func downloadFinishNotiResponse(_ notifiction:Notification) {
        if let _ = notifiction.userInfo?["error"] {
            if let url = notifiction.userInfo?["url"] as? String {
                removeOperation(url)
                cache.remoCache(for: url)
            }
        }
    }
    
    /// 缓存完成通知
    ///
    /// - Parameter notification: 完成通知
    @objc private func cacheCompleteFinishNotiResponse(_ notification:Notification) {
        if let url = notification.userInfo?["url"] as? String {
            if !url.isEmpty {
                removeOperation(url)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
