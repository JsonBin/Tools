//
//  WBBlurImageView.swift
//  WBExtension
//
//  Created by zwb on 17/2/24.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit
import QuartzCore
import Accelerate

// MARK: - 高斯模糊照片处理

public class WBBlurImageView: UIImageView {

    //MARK: - Static Properties
    fileprivate struct WBBlurKey {
        public static let fadeAnimationKey = "FadeAnimationKey"
        public static let maxImageCount: Int = 10
        public static let contentsAnimationKey = "contents"
    }
    
    //MARK: - Instance Properties
    fileprivate var cgImages: [CGImage] = [CGImage]()
    fileprivate var nextBlurLayer: CALayer?
    fileprivate var previousImageIndex: Int = -1
    fileprivate var previousPercentage: CGFloat = 0.0
    open fileprivate(set) var isBlurAnimating: Bool = false
    
    deinit {
        clearMemory()
    }
    
    //MARK: - Life Cycle
    open override func layoutSubviews() {
        super.layoutSubviews()
        nextBlurLayer?.frame = bounds
    }
    
    open func configrationForBlurAnimation(_ boxSize: CGFloat = 100) {
        guard let image = image else { return }
        let baseBoxSize = max(min(boxSize, 200), 0)
        let baseNumber = sqrt(CGFloat(baseBoxSize)) / CGFloat(WBBlurKey.maxImageCount)
        let baseCGImages = [image].flatMap { $0.cgImage }
        cgImages = bluredCGImages(baseCGImages, sourceImage: image, at: 0, to: WBBlurKey.maxImageCount, baseNumber: baseNumber)
    }
    
    fileprivate func bluredCGImages(_ images: [CGImage], sourceImage: UIImage?, at index: Int, to limit: Int, baseNumber: CGFloat) -> [CGImage] {
        guard index < limit else { return images }
        let newImage = sourceImage?.blurEffect(pow(CGFloat(index) * baseNumber, 2))
        let newImages = images + [newImage].flatMap { $0?.cgImage }
        return bluredCGImages(newImages, sourceImage: newImage, at: index + 1, to: limit, baseNumber: baseNumber)
    }
    
    open func clearMemory() {
        cgImages.removeAll(keepingCapacity: false)
        nextBlurLayer?.removeFromSuperlayer()
        nextBlurLayer = nil
        previousImageIndex = -1
        previousPercentage = 0.0
        layer.removeAllAnimations()
    }
    
    //MARK: - Add single blur
    open func addBlurEffect(_ boxSize: CGFloat, times: UInt = 1) {
        guard let image = image else { return }
        self.image = addBlurEffectTo(image, boxSize: boxSize, remainTimes: times)
    }
    
    fileprivate func addBlurEffectTo(_ image: UIImage, boxSize: CGFloat, remainTimes: UInt) -> UIImage {
        guard let blurImage = image.blurEffect(boxSize) else { return image }
        return remainTimes > 0 ? addBlurEffectTo(blurImage, boxSize: boxSize, remainTimes: remainTimes - 1) : image
    }
    
    //MARK: - Percentage blur
    open func blur(_ percentage: CGFloat) {
        let percentage = min(max(percentage, 0.0), 0.99)
        if previousPercentage - percentage  > 0 {
            let index = Int(floor(percentage * 10)) + 1
            if index > 0 {
                setLayers(index, percentage: percentage, currentIndex: index - 1, nextIndex: index)
            }
        } else {
            let index = Int(floor(percentage * 10))
            if index < cgImages.count - 1 {
                setLayers(index, percentage: percentage, currentIndex: index, nextIndex: index + 1)
            }
        }
        previousPercentage = percentage
    }
    
    fileprivate func setLayers(_ index: Int, percentage: CGFloat, currentIndex: Int, nextIndex: Int) {
        if index != previousImageIndex {
            CATransaction.animationWithDuration(0) { layer.contents = self.cgImages[currentIndex] }
            
            if nextBlurLayer == nil {
                let nextBlurLayer = CALayer()
                nextBlurLayer.frame = bounds
                layer.addSublayer(nextBlurLayer)
                self.nextBlurLayer = nextBlurLayer
            }
            
            CATransaction.animationWithDuration(0) {
                self.nextBlurLayer?.contents = self.cgImages[nextIndex]
                self.nextBlurLayer?.opacity = 1.0
            }
        }
        previousImageIndex = index
        
        let minPercentage = percentage * 100.0
        let alpha = min(max((minPercentage - CGFloat(Int(minPercentage / 10.0)  * 10)) / 10.0, 0.0), 1.0)
        CATransaction.animationWithDuration(0) { self.nextBlurLayer?.opacity = Float(alpha) }
    }
    
    //MARK: - Animation blur
    open func startBlurAnimation(_ duration: TimeInterval) {
        if isBlurAnimating { return }
        isBlurAnimating = true
        let count = cgImages.count
        let group = CAAnimationGroup()
        group.animations = cgImages.enumerated().flatMap {
            guard $0.offset < count - 1 else { return nil }
            let anim = CABasicAnimation(keyPath: WBBlurKey.contentsAnimationKey)
            anim.fromValue = $0.element
            anim.toValue = cgImages[$0.offset + 1]
            anim.fillMode = kCAFillModeForwards
            anim.isRemovedOnCompletion = false
            anim.duration = duration / TimeInterval(count)
            anim.beginTime = anim.duration * TimeInterval($0.offset)
            return anim
        }
        group.duration = duration
        group.delegate = self
        group.isRemovedOnCompletion = false
        group.fillMode = kCAFillModeForwards
        layer.add(group, forKey: WBBlurKey.fadeAnimationKey)
        cgImages = cgImages.reversed()
    }

}

// MARK: - Extension CAAnimationDelegate

extension WBBlurImageView : CAAnimationDelegate {
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let _ = anim as? CAAnimationGroup else { return }
        layer.removeAnimation(forKey: WBBlurKey.fadeAnimationKey)
        isBlurAnimating = false
        guard let cgImage = cgImages.first else { return }
        image = UIImage(cgImage: cgImage)
    }
}

// MARK: - Extension CATransaction

extension CATransaction {
    
    public class func animationWithDuration(_ duration: TimeInterval, animation: () -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        animation()
        CATransaction.commit()
    }
}

// MARK: - Extension UIImage

extension UIImage {
    
    public class func blurEffect(_ cgImage: CGImage, boxSize: CGFloat) -> UIImage? {
        return UIImage(cgImage: (cgImage.blurEffect(boxSize) ?? cgImage))
    }
    
    public func blurEffect(_ boxSize: CGFloat) -> UIImage? {
        guard let imageRef = bluredCGImage(boxSize) else { return nil }
        return UIImage(cgImage: imageRef)
    }
    
    public func bluredCGImage(_ boxSize: CGFloat) -> CGImage? {
        return cgImage?.blurEffect(boxSize)
    }
}

// MARK: - Extension CGImage

extension CGImage {
    
    func blurEffect(_ boxSize: CGFloat) -> CGImage? {
        
        let boxSize = boxSize - (boxSize.truncatingRemainder(dividingBy: 2)) + 1
        
        let inProvider = self.dataProvider
        
        let height = vImagePixelCount(self.height)
        let width = vImagePixelCount(self.width)
        let rowBytes = self.bytesPerRow
        
        let inBitmapData = inProvider?.data
        let inData = UnsafeMutableRawPointer(mutating: CFDataGetBytePtr(inBitmapData))
        var inBuffer = vImage_Buffer(data: inData, height: height, width: width, rowBytes: rowBytes)
        
        let outData = malloc(self.bytesPerRow * self.height)
        var outBuffer = vImage_Buffer(data: outData, height: height, width: width, rowBytes: rowBytes)
        
        vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, UInt32(boxSize), UInt32(boxSize), nil, vImage_Flags(kvImageEdgeExtend))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: outBuffer.data, width: Int(outBuffer.width), height: Int(outBuffer.height), bitsPerComponent: 8, bytesPerRow: outBuffer.rowBytes, space: colorSpace, bitmapInfo: self.bitmapInfo.rawValue)
        let imageRef = context?.makeImage()
        
        free(outData)
        
        return imageRef
    }
}
