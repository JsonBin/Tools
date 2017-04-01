//
//  WBWebImageDSL.swift
//  WBExtension
//
//  Created by zwb on 17/3/2.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

// MARK: - UIButton

public struct WBButtonDSL {
    
    public let dsl: UIButton
    
    /// init
    ///
    /// - Parameter button: button
    public init(button: UIButton) {
        dsl = button
    }
}

extension WBButtonDSL {
    
    /// 设置按钮的网络图片
    ///
    /// - Parameters:
    ///   - url: 图片URL
    ///   - holder: 占位图
    ///   - state: 按钮状态
    func setImageWithURL(_ url:ImageURLConvertible, placeHolder holder:UIImage? = nil, forState state:UIControlState) -> Void {
        if let placeImage = holder {
            dsl.setImage(placeImage, for: state)
        }
        WBWebImageManager.default.downloadImage(url) { (image) in
            self.dsl.setImage(image, for: state)
        }
    }
    
    /// 设置按钮背景网络图片
    ///
    /// - Parameters:
    ///   - url: 图片URL
    ///   - holer: 占位图
    ///   - state: 按钮状态
    func setBackgroundImageWithURL(_ url:ImageURLConvertible, placeHolder holer:UIImage? = nil, forState state:UIControlState) -> Void{
        if let placeImage = holer {
            dsl.setBackgroundImage(placeImage, for: state)
        }
        WBWebImageManager.default.downloadImage(url) { (image) in
            self.dsl.setBackgroundImage(image, for: state)
        }
    }
}

// MARK: - UIImageView

public struct WBImageViewDSL {
    
    public let dsl: UIImageView
    
    /// init
    ///
    /// - Parameter imageView: imageView
    public init(imageView: UIImageView) {
        dsl = imageView
    }
}

extension WBImageViewDSL {

    /// 设置ImageView的网络图片
    ///
    /// - Parameters:
    ///   - url: 图片URL
    ///   - holder: 占位图
    func setImageWithURL(_ url:ImageURLConvertible, placeHolder holder:UIImage? = nil) {
        if let placeImage = holder {
            dsl.image = placeImage
        }
        WBWebImageManager.default.downloadImage(url) { (downImage) in
            self.dsl.image = downImage
        }
    }
}


