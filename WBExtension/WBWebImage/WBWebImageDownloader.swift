//
//  WBWebImageDownloader.swift
//  WBExtension
//
//  Created by zwb on 17/3/2.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation


/// Image URL Protocol
public protocol ImageURLConvertible {
    
    func wbURL() throws -> URL
}

// MARK: - Extension String To Image URL Protocol
extension String : ImageURLConvertible{
    public func wbURL() throws -> URL {
        guard let url = URL(string: self) else { throw WBError.invalidURL(url:self) }
        return url
    }
}

// MARK: - Extension URL To Image URL Protocol
extension URL : ImageURLConvertible {
    public func wbURL() throws -> URL { return self }
}


// MARK: - Extension URLComponents To Image URL Protocol
extension URLComponents: ImageURLConvertible {
    public func wbURL() throws -> URL {
        guard let url = url else { throw WBError.invalidURL(url: self) }
        return url
    }
}

// MARK: - 下载类

public class WBWebImageDownloader  {
    
    /// 所有的下载回调
    public lazy var callBacks:[WBWebImageCallBack] = {
        return [WBWebImageCallBack]()
    }()
    
    /// 下载的task
    public var task: URLSessionDataTask?
    
    /// 下载之后的image，下载之前为nil
    public var image: UIImage?
    
    /// 下载结束的标志
    public var downFinish: Bool
    
    /// 下载的url
    private var _url: URL
    
    /// 下载的session
    private var _session:URLSession?
    
    /// 初始化下载器
    ///
    /// - Parameters:
    ///   - url: 下载地址
    ///   - sess: 下载session
    /// - Throws: 下载地址不符合，抛出异常
    public init(_ url:ImageURLConvertible, session sess: URLSession) throws {
        _url = try url.wbURL()
        _session = sess
        downFinish = false
    }
    
    /// 开始下载文件
    public func downloadImageWithUrlString() {
        
        downloadImageWithRequest(URLRequest(url: _url))
    }
    
    /// 开始网络请求
    ///
    /// - Parameter request: 将要响应的Request
    private func downloadImageWithRequest(_ request:URLRequest) {
        
        task = _session!.dataTask(with: request, completionHandler: { [unowned self] (data, response, error) in
            
            guard let data = data, let _ = error else {
                // 下载错误
                DispatchQueue.main_safe {
                    NotificationCenter.default.post(name: WBWebImageDownloadFinishNotification, object: nil, userInfo: ["error":WBError.descriptError(10003, message: "任务取消或错误"), "url":self._url.absoluteString])
                }
                return
            }
            
            self._session = nil
            let image = UIImage(data: data)
            self.image = image
            self.downFinish = true
            
            guard let newImage = image else{
                // 下载失败
                DispatchQueue.main_safe {
                    NotificationCenter.default.post(name: WBWebImageDownloadFinishNotification, object: nil, userInfo: ["error":WBError.descriptError(10000, message: "图片下载失败:\(self._url)"), "url":self._url.absoluteString])
                }
                return
            }
            
            // 保存数据
            WBWebImageCache.default.cacheObjc(data, forKey: self._url.absoluteString)
            
            for back in self.callBacks {
                DispatchQueue.main_safe {
                    back(newImage)
                }
            }
            
            // 发送通知
            DispatchQueue.main_safe {
                NotificationCenter.default.post(name: WBWebImageDownloadFinishNotification, object: nil, userInfo: ["url":self._url.absoluteString, "image":self.image!])
            }
        })
    }
}
