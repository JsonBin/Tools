//
//  WBWebImage+DispatchQueue.swift
//  WBExtension
//
//  Created by zwb on 17/3/2.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation


extension DispatchQueue {
    
    static func main_safe(_ closure:@escaping () -> Void) {
        main.async {
            closure()
        }
    }
}

// MARK: - 图片线程处理类

public class WBWebImageOperation : Operation {
    
    public var downloader: WBWebImageDownloader?
    
    
    /// init operation
    ///
    /// - Parameters:
    ///   - url: image url
    ///   - sess: image session
    public init(_ url:ImageURLConvertible, session sess:URLSession) {
        downloader = try? WBWebImageDownloader(url, session: sess)
        downloader?.downloadImageWithUrlString()
    }
    
    public override func start() {
        super.start()
        downloader?.task?.resume()
    }
    
    public override func cancel() {
        super.cancel()
        downloader?.task?.cancel()
    }
}
