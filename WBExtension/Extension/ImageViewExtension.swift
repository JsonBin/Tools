//
//  ImageViewExtension.swift
//  WBExtension
//
//  Created by zwb on 17/2/27.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit
import ImageIO

// MARK: - Gif Tool (UIImageView上的gif图片的播放/暂停/结束)

public extension  UIImageView  {
    
    /// 私有存储key
    private struct wbImageGifKey {
        public static let kGifImages = UnsafeRawPointer(bitPattern: "wbImageViewGifImages".hashValue)
        public static let kGifDuration = UnsafeRawPointer(bitPattern: "wbImageViewGifDuration".hashValue)
    }
    
    /// 异步线程
    private var asynQueue: DispatchQueue{
        let name = String(format: "com.wbwebimageview.gif-%08x%08x", arc4random(),arc4random())
        return DispatchQueue(label: name, attributes: .concurrent)
    }
    
    /// 获取GIF图片的所有的CGImage数组
    public var gifImages: [CGImage]!
        {
        set{
            objc_setAssociatedObject(self, wbImageGifKey.kGifImages, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let array = objc_getAssociatedObject(self, wbImageGifKey.kGifImages) else {
                let arr = [CGImage]()
                objc_setAssociatedObject(self, wbImageGifKey.kGifImages, arr, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return arr
            }
            return array as! [CGImage]
        }
    }
    
    /// 获取GIF的动画时长
    public var gifDuration: CGFloat!
        {
        set{
            objc_setAssociatedObject(self, wbImageGifKey.kGifDuration, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get{
            guard let duration = objc_getAssociatedObject(self, wbImageGifKey.kGifDuration) else {
                return 0.0
            }
            return duration as! CGFloat
        }
    }
    
    
    /// 初始化并设置是否循环播放
    ///
    /// - Parameters:
    ///   - name: gif网络URL或本地名字
    ///   - canRepeat: 是否重复播放
    public convenience init(gifPath name:String, isRepeat canRepeat:Bool = true) {
        self.init(gifNameOrURL: name, repeatCount: canRepeat ? .greatestFiniteMagnitude : 1)
    }
    
    ///  初始化并自动播放
    ///
    /// - Parameters:
    ///   - name: gif文件URL或名字
    ///   - count: 重复次数
    public convenience init(gifNameOrURL name:String, repeatCount count:CGFloat = .greatestFiniteMagnitude) {
        self.init()
        
        asynQueue.async {
            var url : URL!
            if name.hasPrefix("http"){
                url = URL(string: name)!.absoluteURL
            }else{
                let path = Bundle.main.path(forAuxiliaryExecutable: name)!
                url = URL(fileURLWithPath: path).absoluteURL
            }
            let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil)
            let dic = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil) as! NSDictionary
            let height = (dic.object(forKey: "PixelHeight") as! NSNumber).floatValue
            let width = (dic.object(forKey: "PixelWidth") as! NSNumber).floatValue
            let _ = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
            DispatchQueue.main.async {
                self.startgif(imageSource!, repeatCount: count)
            }
        }
    }
    
    
    /// 开始播放
    ///
    /// - Parameters:
    ///   - source: 数据源
    ///   - count: 重复次数
    public func startgif(_ source:CGImageSource, repeatCount animationCount:CGFloat) {
        
        asynQueue.async {
            var delayTimes = [NSNumber]()
            let count = CGImageSourceGetCount(source)
            if count <= 1{ return }
            for i in 0..<count {
                let image = CGImageSourceCreateImageAtIndex(source, i, nil)
                self.gifImages.append(image!)
                
                let propertiesRef = CGImageSourceCopyPropertiesAtIndex(source, i, nil)
                let properties = propertiesRef as! NSDictionary
                let gifProperties = properties.object(forKey: kCGImagePropertyGIFDictionary) as! NSDictionary
                let time = gifProperties.object(forKey: "DelayTime") as! NSNumber
                delayTimes.append(time)
            }
            var times:Float = 0
            for time in delayTimes {
                times += time.floatValue
            }
            self.gifDuration = CGFloat(times)
            let keytimes = self.getKeyTimesFromDelayTimeArray(delayTimes, totalTime: times)
            DispatchQueue.main.async(execute: {  [unowned self] in
                let animation = CAKeyframeAnimation(keyPath: "contents")
                animation.duration = CFTimeInterval(times)
                animation.values = self.gifImages
                animation.keyTimes = keytimes
                animation.repeatCount = Float(animationCount)
                animation.fillMode = kCAFillModeForwards
                animation.isRemovedOnCompletion = false
                animation.delegate = self
                self.clipsToBounds = true
                self.layer.add(animation, forKey: "gifAnimation")
            })
        }
    }
    
    /// 暂停
    public func pauseGif() {
        let pausetime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.timeOffset = pausetime
        layer.speed = 0.0
    }
    
    /// 恢复
    public func resumeGif() {
        let pausetime = layer.timeOffset
        let starttime = CACurrentMediaTime() - pausetime
        layer.timeOffset = 0.0
        layer.beginTime = starttime
        layer.speed = 1.0
    }
    
    /// 销毁
    public func invalidGif() {
        layer.removeAnimation(forKey: "gifAnimation")
        layer.contents = gifImages.first
    }
    
    // MARK:  - Private Methods
    
    /// string转为url
    ///
    /// - Parameter string: string
    /// - Returns: url
    private func urlFromString(_ string:String) -> URL{
        
        if string.hasPrefix("http"){
            return URL(string: string)!.absoluteURL
        }
        return URL(fileURLWithPath: string).absoluteURL
    }
    
    /// 获取每一帧的时长数组
    ///
    /// - Parameters:
    ///   - delayTimes: 所有的延迟时间
    ///   - time: 一共需执行的次数
    /// - Returns: 每一帧延时数组
    private func getKeyTimesFromDelayTimeArray(_ delayTimes:[NSNumber], totalTime time:Float) -> [NSNumber] {
        var arrays = [NSNumber]()
        arrays.append(0)
        var current:Float = 0
        for number in delayTimes {
            current += number.floatValue
            arrays.append(NSNumber(value: current / time))
        }
        return arrays
    }
}

// MARK: - Extension UIimageView CAAnimationDelegate

extension UIImageView : CAAnimationDelegate {
    
    /// 动画开始通知
    ///
    /// - Parameter anim: animation
    public func animationDidStart(_ anim: CAAnimation) {
        NotificationCenter.default.post(name: Notification.Name.WBImageViewGif.wbKImageViewGifStart, object: nil)
    }
    
    /// 动画结束的通知
    ///
    /// - Parameters:
    ///   - anim: animation
    ///   - flag: 结束标志
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            NotificationCenter.default.post(name: Notification.Name.WBImageViewGif.wbKImageViewGifFinish, object: nil)
        }else{
            NotificationCenter.default.post(name: Notification.Name.WBImageViewGif.wbKImageViewGifCancle, object: nil)
        }
    }
}

// MARK: - Extension Notification.Name

extension Notification.Name {
    
    /// GIF动画通知名称
    public struct WBImageViewGif {
        public static let wbKImageViewGifFinish = Notification.Name("kImageViewGifFinished")
        public static let wbKImageViewGifStart = Notification.Name("kImageViewGifstart")
        public static let wbKImageViewGifCancle = Notification.Name("kImageViewGifcancle")
    }
}
