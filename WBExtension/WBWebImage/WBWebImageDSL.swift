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
    func setImageWithURL(_ url:ImageURLConvertible, placeHolder holder:UIImage? = nil, forState state:UIControlState = .normal) -> Void {
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
    func setBackgroundImageWithURL(_ url:ImageURLConvertible, placeHolder holer:UIImage? = nil, forState state:UIControlState = .normal) -> Void{
        if let placeImage = holer {
            dsl.setBackgroundImage(placeImage, for: state)
        }
        WBWebImageManager.default.downloadImage(url) { (image) in
            self.dsl.setBackgroundImage(image, for: state)
        }
    }
    
    /// 返回带圆角的网络图片
    ///
    /// - Parameters:
    ///   - url: 图片url
    ///   - radius: 半径
    ///   - width: 图片宽度
    ///   - borderWidth: 边线宽度
    ///   - color: 边线颜色
    ///   - holder: 占位图
    func setCornerImageWithURL(_ url: ImageURLConvertible, corner radius:CGFloat = 0, imageWidth width:CGFloat = 0, border borderWidth:CGFloat = 0, borderColor color:UIColor = .white,  placeHolder holder: UIImage? = nil,  forState state:UIControlState = .normal) {
        if let placeImage = holder {
            dsl.setImage(placeImage, for: state)
        }
        WBWebImageManager.default.downloadImage(url) { (downImage) in
            let image = downImage.wb_cornerRadius(radius, imageWidth: width, borderWidth: borderWidth, borderColor: color, viewRect: nil, model: .aspectFill)
            self.dsl.setImage(image, for: state)
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
            DispatchQueue.main_safe {
                self.dsl.image = downImage
                self.dsl.setNeedsLayout()
            }
        }
    }
    
    /// 返回带圆角的网络图片
    ///
    /// - Parameters:
    ///   - url: 图片url
    ///   - radius: 半径
    ///   - width: 图片宽度
    ///   - borderWidth: 边线宽度
    ///   - color: 边线颜色
    ///   - holder: 占位图
    func setCornerImageWithURL(_ url: ImageURLConvertible, corner radius:CGFloat = 0, imageWidth width:CGFloat = 0, border borderWidth:CGFloat = 0, borderColor color:UIColor = .white,  placeHolder holder: UIImage? = nil) {
        if let placeImage = holder {
            dsl.image = placeImage
        }
        WBWebImageManager.default.downloadImage(url) { (downImage) in
            self.dsl.image = downImage.wb_cornerRadius(radius, imageWidth: width, borderWidth: borderWidth, borderColor: color, viewRect: nil)
        }
    }
}

public struct WBUIViewDSL {
    
    public let dsl: UIView
    
    /// Init
    ///
    /// - Parameter dsl: UIView
    public init(view: UIView) {
        self.dsl = view
    }
}

extension WBUIViewDSL {
    
    /// 设置UIView的网络图片
    ///
    /// - Parameters:
    ///   - url: 图片URL
    ///   - holder: 占位图
    func setImageWithURL(_ url: ImageURLConvertible, placeHolder holder: UIImage? = nil) {
        if let placeImage = holder {
            dsl.layer.contents = placeImage.cgImage
        }
        WBWebImageManager.default.downloadImage(url) { (downImage) in
            self.dsl.layer.contents = downImage.cgImage
        }
    }
    
    /// 返回带圆角的网络图片
    ///
    /// - Parameters:
    ///   - url: 图片url
    ///   - radius: 半径
    ///   - width: 图片宽度
    ///   - borderWidth: 边线宽度
    ///   - color: 边线颜色
    ///   - holder: 占位图
    func setCornerImageWithURL(_ url: ImageURLConvertible, corner radius:CGFloat = 0, imageWidth width:CGFloat = 0, border borderWidth:CGFloat = 0, borderColor color:UIColor = .white,  placeHolder holder: UIImage? = nil) {
        if let placeImage = holder {
            dsl.layer.contents = placeImage.cgImage
        }
        WBWebImageManager.default.downloadImage(url) { (downImage) in
            self.dsl.layer.contents = downImage.wb_cornerRadius(radius, imageWidth: width, borderWidth: borderWidth, borderColor: color, viewRect: nil)?.cgImage
        }
    }
}

