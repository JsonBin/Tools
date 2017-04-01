//
//  WBWebImage.swift
//  WBExtension
//
//  Created by zwb on 17/3/2.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

// 默认缓存大小
public let WBWebImageCacheDefaultCost = 5_000_000  // 5MB

// 默认缓存时间
public let WBWebImageCacheDefaultExpirateTime = 7 * 24 * 60 * 60  // 7天

// 回调
public typealias WBWebImageCallBack = (_ image:UIImage) -> Void

public let WBWebImageDownloadFinishNotification = Notification.Name("WBWebImage_downloadFinish")
public let WBWebImageCacheCompleteNotification = Notification.Name("WBWebImage_cachecomplete")


// MARK: - Button Set Net Image

extension UIButton  {
    
    @available(iOS 8.0, *)
    public var wb:WBButtonDSL {
        return WBButtonDSL(button: self)
    }
}


// MARK: - ImageView Set Net Image

extension UIImageView {
    
    @available(iOS 8.0, *)
    public var wb:WBImageViewDSL {
        return WBImageViewDSL(imageView: self)
    }
}
