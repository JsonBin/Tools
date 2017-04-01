//
//  WBRefreshGifHeader.swift
//  WBExtension
//
//  Created by zwb on 17/3/13.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation
import ImageIO

/// GIF 动画刷新的header
open class WBRefreshGifHeader: WBRefreshStateHeader {
    
    /// gif View
    open var gifView: UIImageView! {
        if let view = _gifView{
            return view
        }
        _gifView = UIImageView()
        addSubview(_gifView)
        return _gifView
    }
    private var _gifView:UIImageView!
    
    /// 本地GIF图片名字
    open var gifDictionary: [WBRefresh.State: String]! {
        didSet{
            for (state,name) in gifDictionary {
                setImagesForName(name, forState: state)
            }
        }
    }
    
    /// 私有存储所有状态对应的image以及动画时长
    private typealias imageState = WBRefresh.State
    private var stateImages = [imageState:[UIImage]]()
    private var stateDurations = [imageState:TimeInterval]()
    
    // MARK: -  重写父类
    open override func prepare() {
        super.prepare()
        
        labelLeftInset = 20
    }
    
    open override func placeSubviews() {
        super.placeSubviews()
        
        if gifView.constraints.count != 0 { return }
        
        gifView.frame = bounds
        if stateLabel.isHidden && lastUpdatedTimeLabel.isHidden {
            gifView.contentMode = .center
        }else{
            gifView.contentMode = .right
            
            let stateWidth = stateLabel.wb_textWidth
            var timeWidth: CGFloat = 0
            if !lastUpdatedTimeLabel.isHidden {
                timeWidth = lastUpdatedTimeLabel.wb_textWidth
            }
            let textWidth = max(stateWidth, timeWidth)
            gifView.ve.width = ve.width * 0.5 - textWidth * 0.5 - labelLeftInset
        }
    }
    
    open override func setState(_ refreshState: WBRefresh.State) {
        if refreshState == state { return }
        
        super.setState(refreshState)
        // 根据状态做事
        if state == .pulling || state == .refreshing {
            guard let images = stateImages[state] else { return }
            if images.count == 0 { return }
            
            if images.count == 1 {  // 一张图片
                gifView.image = images.first!
            }else{
                // 多张图片
                gifView.animationImages = images
                if let duration = stateDurations[state] {
                    gifView.animationDuration = duration
                }
                gifView.startAnimating()
            }
        }else if state == .default {
            gifView.stopAnimating()
        }
    }
    
    open override func setPullPercent(_ percent: CGFloat) {
        super.setPullPercent(percent)
        
        guard let images = stateImages[.default] else { return }
        if state != .default || images.count == 0 { return }
        
        gifView.stopAnimating()
        var index = Int(CGFloat(images.count) * percent)
        if index >= images.count { index = images.count - 1 }
        gifView.image = images[index]
    }
    
    // MARK: - Private
    private func setImagesForName(_ gifName:String, forState state:WBRefresh.State) -> Void {
        let name = String(format: "com.wbrefresh.GifHeader-%08x%08x", arc4random(),arc4random())
        DispatchQueue(label: name, attributes: .concurrent).async {
            var url : URL!
            if gifName.hasPrefix("http"){
                url = URL(string: gifName)!.absoluteURL
            }else{
                let path = Bundle.main.path(forAuxiliaryExecutable: gifName)!
                url = URL(fileURLWithPath: path).absoluteURL
            }
            let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil)!
            let dic = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as! NSDictionary
            let height = (dic.object(forKey: "PixelHeight") as! NSNumber).floatValue
            DispatchQueue.main.async {
                if CGFloat(height) > self.ve.height{
                    self.ve.height = CGFloat(height)
                }
            }
            // 照片
            var images = [UIImage]()
            // 时间
            var durations: TimeInterval = 0
            let count = CGImageSourceGetCount(imageSource)
            for i in 0..<count {
                let cgimage = CGImageSourceCreateImageAtIndex(imageSource, i, nil)
                let image = UIImage(cgImage: cgimage!)
                images.append(image)
                
                let propertiesRef = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil)
                let properties = propertiesRef as! NSDictionary
                let gifProperties = properties.object(forKey: kCGImagePropertyGIFDictionary) as! NSDictionary
                let time = gifProperties.object(forKey: "DelayTime") as! NSNumber
                durations += time.doubleValue
            }
            self.stateImages[state] = images
            self.stateDurations[state] = durations
        }
    }
}
