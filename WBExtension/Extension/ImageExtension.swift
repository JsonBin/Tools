//
//  ImageExtension.swift
//  WBExtension
//
//  Created by zwb on 17/2/28.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation
import ImageIO

// MARK: - 图片处理延展

public extension UIImage {
    
    // MARK: - 图片的填充模式
    public enum WBImageContentModel : UInt8 {
        case aspectFit  // 自适应
        case aspectFill  // 填充
        case fill     // 拉伸
    }
    
    // MARK: - 高性能按图片名检索本地图片
    @discardableResult
    public class func wb_imageNamed(_ name:String) -> UIImage? {
        
        guard let path = Bundle.main.path(forResource: name, ofType: nil) else {
            guard let path = Bundle.main.path(forResource: name, ofType: "png") else {
                return nil
            }
            return wb_imageWithUrl(URL(fileURLWithPath: path))
        }
        return wb_imageWithUrl(URL(fileURLWithPath: path))
    }
    
    // MARK: - 高性能返回无延迟解压图片
    @discardableResult
    public class func wb_imageWithUrl(_ url:URL) -> UIImage? {
        let options = [(kCGImageSourceShouldCache as String): true] as CFDictionary
        if let source = CGImageSourceCreateWithURL(url as CFURL, nil){
            if let imageRef = CGImageSourceCreateImageAtIndex(source, 0, options){
                let image = UIImage(cgImage: imageRef)
                return image
            }
            return nil
        }
        return nil
    }
    
    // MARK: - 获取带圆角的图片
    /*
     radius:返回图片的圆角半径
     圆角半径不可超过图片尺寸的1/2,否则按1/2处理
     
     width:返回图片的宽度
     返回的图片为一个宽高相等的矩形区域，但图片且居中显示
     
     mode:返回图片的填充模式
     适应模式:以原图片比例，能显示全部图片的最大尺寸进行填充
     填充模式:以原图片比例，图片能充满容器的最小尺寸进行填充
     拉伸模式:以拉伸图片能够使图片充满容器的尺寸进行填充
     */
    
    /// 对图片进行圆角裁剪
    ///
    /// - Parameters:
    ///   - radius: 圆角的大小
    ///   - width: 需要返回的图片的宽度
    ///   - borWidth: 边线的宽度
    ///   - color: 边线的颜色
    ///   - rect: 指定裁剪的大小
    ///   - contentModel: 填充的模式
    /// - Returns: 裁剪后的图片
    @discardableResult public func wb_cornerRadius(_ radius:CGFloat, imageWidth width:CGFloat = 0, borderWidth borWidth:CGFloat = 0, borderColor color:UIColor? = nil, viewRect rect:CGRect? = nil, model contentModel: WBImageContentModel = .aspectFit) -> UIImage? {
        
        /// 根据需要设置的view视图大小尺寸来设置图片的大小
        if var rect = rect {
            
            // 剪切图片时圆角不能设置小于0!
            let radiu = radius < 0 ? 0 : radius
            
            rect = CGRect(x: rect.origin.x + borWidth, y: rect.origin.y + borWidth, width: rect.size.width - 2 * borWidth, height: rect.size.height - 2 * borWidth)
            
            var size = CGSize.zero
            size.width = self.size.width < 0 ? -self.size.width : self.size.width
            size.height = self.size.height < 0 ? -self.size.height : self.size.height
            let center = CGPoint(x: rect.size.width / 2, y: rect.size.height / 2)
            switch contentModel {
            case .aspectFill, .aspectFit:
                if rect.width < 0.01 || rect.height < 0.01 || size.width < 0.01 || size.height < 0.01 {
                    rect.origin = center
                    rect.size = .zero
                }else{
                    let scale: CGFloat
                    if contentModel == .aspectFit {
                        if size.width / size.height < rect.size.width / rect.size.height {
                            scale = rect.size.height / size.height
                        }else{
                            scale = rect.size.width / size.width
                        }
                    }else{
                        if size.width / size.height < rect.size.width / rect.size.height {
                            scale = rect.size.width / size.width
                        }else{
                            scale = rect.size.height / size.height
                        }
                    }
                    size.width *= scale
                    size.height *= scale
                    rect.size = size
                    rect.origin = CGPoint(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5)
                }
            default: break
            }
            
            // 以最大长度开启绘图
            UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
            
            defer {
                UIGraphicsEndImageContext()
            }
            
            // 获取上下文
            guard let context = UIGraphicsGetCurrentContext() else { return self }
            
            context.saveGState()
            //绘制一个圆形的贝塞尔曲线，并做遮罩
            let bezierPath = UIBezierPath(roundedRect: rect, cornerRadius: radiu)
            bezierPath.addClip()
            
            context.addRect(rect)
            context.clip()
            draw(in: rect) // 指定frame画图
            context.rotate(by: CGFloat(M_PI_2))
            
            context.restoreGState()
            
            // 设置边线的颜色及宽度
            bezierPath.lineWidth = borWidth
            bezierPath.lineJoinStyle = .round
            bezierPath.lineCapStyle = .round
            color?.setStroke()
            bezierPath.stroke()
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            return image
            
        }else{
            
            let originScale = size.width / size.height
            let height = width / originScale
            let scale = UIScreen.main.scale
            let maxV = max(width, height)
            // 剪切图片时圆角不能设置小于0!
            let radiu = radius < 0 ? 0 : radius
            var imageFrame:CGRect!
            // 根据图片填充模式来绘制图片的frame
            if contentModel == .aspectFit {  // 自适应模式
                if originScale > 1{
                    imageFrame = CGRect(x: 0,
                                        y: (width - height) / 2,
                                        width: width,
                                        height: height)
                }else{
                    imageFrame = CGRect(x: (height - width) / 2,
                                        y: 0,
                                        width: width,
                                        height: height)
                }
            }else if contentModel == .aspectFill {  // 填充模式
                var newHeight:CGFloat!
                var newWidth:CGFloat!
                if originScale > 1{
                    newHeight = width
                    newWidth = newHeight * originScale
                    imageFrame = CGRect(x: -(newWidth - newHeight) / 2,
                                        y: 0,
                                        width: newWidth,
                                        height: newHeight)
                }else{
                    newWidth = height
                    newHeight = newWidth / originScale
                    imageFrame = CGRect(x: 0,
                                        y: -(newHeight - newWidth) / 2,
                                        width: newWidth,
                                        height: newHeight)
                }
            }else{ // 拉伸模式
                imageFrame = CGRect(x: 0, y: 0, width: maxV, height: maxV)
            }
            
            // 以最大长度开启绘图
            UIGraphicsBeginImageContextWithOptions(CGSize(width: maxV, height: maxV), false, scale)
            
            defer {
                UIGraphicsEndImageContext()
            }
            
            // 获取上下文
            guard let context = UIGraphicsGetCurrentContext() else { return self }
            context.saveGState()
            
            //绘制一个圆形的贝塞尔曲线，并做遮罩
            let bezierPath = UIBezierPath(roundedRect: CGRect(x: borWidth, y: borWidth, width: maxV - 2 * borWidth, height: maxV - 2 * borWidth), cornerRadius: radiu)
            bezierPath.addClip()
            
            context.addRect(imageFrame)
            context.clip()
            draw(in: imageFrame) // 指定frame画图
            context.rotate(by: CGFloat(M_PI_2))
            
            context.restoreGState()
            
            // 设置边线的颜色及宽度
            bezierPath.lineWidth = borWidth
            bezierPath.lineJoinStyle = .round
            bezierPath.lineCapStyle = .round
            color?.setStroke()
            bezierPath.stroke()
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            return image
        }
        
    }
    
    // MARK: - 按给定path剪裁图片
    /**
     path:路径，剪裁区域。
     mode:填充模式
     
     注:
     1.路径中心对应图片中心
     2.路径只决定剪裁图形，不影响剪裁位置
     */
    @discardableResult
    public func wb_clipImage(_ path:UIBezierPath, model contentModel:WBImageContentModel = .aspectFit) -> UIImage? {
        
        let originScale = size.width / size.height
        let boxBounds = path.bounds
        var width = boxBounds.size.width
        var height = width / originScale
        switch contentModel {
        case .aspectFit:
            if height > boxBounds.size.height {
                height = boxBounds.size.height
                width = height * originScale
            }
        case .aspectFill:
            if height < boxBounds.size.height {
                height = boxBounds.size.height
                width = height * originScale
            }
        case .fill:
            if height != boxBounds.size.height{
                height = boxBounds.size.height
            }
        }
        
        // 开启绘图
        UIGraphicsBeginImageContextWithOptions(boxBounds.size, false, UIScreen.main.scale)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        // 获取上下文
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        // path 归零
        let newPath = path.copy() as! UIBezierPath
        newPath.apply(CGAffineTransform(translationX: -path.bounds.origin.x, y: -path.bounds.origin.y))
        newPath.addClip()
        
        // 移动圆点至图片中心
        context.translateBy(x: boxBounds.size.width / 2.0, y: boxBounds.size.height / 2.0)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage!, in: CGRect(x: -width/2, y: -height/2, width: width, height: height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return newImage
    }
    
    // MARK: - 按给定颜色生成图片
    @discardableResult
    public class func wb_imageWithColor(_ color:UIColor) -> UIImage? {
        
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - 获取旋转角度的图片
    /**
     注:角度计数单位为弧度制
     */
    @discardableResult
    public func wb_rotateImageWithAngle(_ angle:CGFloat) -> UIImage? {
        
        let rotateViewBox = UIView(frame: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        let transform = CGAffineTransform(rotationAngle: angle)
        rotateViewBox.transform = transform
        let rotateSize = rotateViewBox.frame.size
        
        UIGraphicsBeginImageContextWithOptions(rotateSize, false, UIScreen.main.scale)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        // 获取上下文
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        context.translateBy(x: rotateSize.width / 2.0, y: rotateSize.height / 2.0)
        context.scaleBy(x: 1.0, y: -1.0)
        context.rotate(by: -angle)
        context.draw(cgImage!, in: CGRect(x: -size.width / 2.0, y: -size.height/2.0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image
    }
    
    // MARK: - 以灰色空间生成图片
    public var wb_convertGrayImage: UIImage? {
        
        let width = size.width
        let height = size.height
        let colorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 4*Int(width), space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue) else{
            return nil
        }
        context.draw(cgImage!, in: CGRect(x: 0.0, y: 0.0, width: width, height: height))
        guard let contextRef = context.makeImage() else{ return nil }
        return UIImage(cgImage: contextRef)
    }
    
    // MARK: - 取图片某点颜色
    /**
     point:取色点
     
     注:以图片自身宽高作为坐标系
     */
    @discardableResult
    public func wb_colorAtPoint(_ point:CGPoint) -> UIColor? {
        
        if !CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height).contains(point) { return nil }
        
        let pointX = trunc(point.x)
        let pointY = trunc(point.y)
        let width = size.width
        let height = size.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let pixelData = UnsafeMutableRawPointer.allocate(bytes: 4, alignedTo: 0)
        
        // 创建1*1画布
        guard let context = CGContext(data: pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue) else {
            return nil
        }
        context.setBlendMode(.copy)
        context.translateBy(x: -pointX, y: pointY-height)
        // 绘图
        context.draw(cgImage!, in: CGRect(x: 0.0, y: 0.0, width: width, height: height))
        // 取色
        let red = CGFloat(pixelData.advanced(by: 0).hashValue) / 255.0
        let green = CGFloat(pixelData.advanced(by: 1).hashValue) / 255.0
        let blue = CGFloat(pixelData.advanced(by: 2).hashValue) / 255.0
        let alpha = CGFloat(pixelData.advanced(by: 3).hashValue) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // MARK: - 转换图片为Base64字符串
    public var wb_imageToBase64String: String {
        var imageData:Data!
        var mimeType:String!
        if imageHasAlpha {
            imageData = UIImagePNGRepresentation(self)
            mimeType = "image/png"
        }else{
            imageData = UIImageJPEGRepresentation(self, 1.0)
            mimeType = "image/jpg"
        }
        return "data:\(mimeType);base64:\(imageData.base64EncodedString())"
    }
    
    // MARK: - Base64转换为图片
    @discardableResult
    public class func wb_imageWithBase64String(_ base64String:String) -> UIImage? {
        let url = URL(string: base64String)
        do {
            let data = try Data(contentsOf: url!)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    // MARK: - 纠正图片方向
    public var wb_fixOrientation: UIImage? {
        if imageOrientation == .up { return self }
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        switch imageOrientation {
        case .down, .downMirrored:
            transform = CGAffineTransform(translationX: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
        case .left, .leftMirrored:
            transform = CGAffineTransform(translationX: size.width, y: 0.0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
        case .right, .rightMirrored:
            transform = CGAffineTransform(translationX: 0.0, y: size.height)
            transform = transform.rotated(by: -CGFloat(M_PI_2))
        case .up, .upMirrored:
            break
        }
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = CGAffineTransform(translationX: size.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .leftMirrored, .rightMirrored:
            transform = CGAffineTransform(translationX: size.height, y: 0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .up, .down, .left, .right:
            break
        }
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        guard let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0, space: cgImage!.colorSpace!, bitmapInfo: cgImage!.bitmapInfo.rawValue) else{
            /*fatalError("[\(#file)].[\(#line)]:\(#function).Reason: get the new context is error!")*/
            return self
        }
        context.concatenate(transform)
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage!, in: CGRect(x: 0.0, y: 0.0, width: size.height, height: size.width))
        default:
            context.draw(cgImage!, in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        }
        guard let imageRef = context.makeImage() else{
            return nil
        }
        return UIImage(cgImage: imageRef)
    }
    
    // MARK: - 按给定的方向旋转图片
    @discardableResult
    public func wb_rotateWithOrient(_ orient:UIImageOrientation) -> UIImage? {
        var bounds = CGRect.zero
        var rect = CGRect.zero
        var transform = CGAffineTransform.identity
        
        rect.size = size
        bounds = rect
        switch orient {
        case .up:
            return self
        case .upMirrored:
            transform = transform.translatedBy(x: rect.size.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .down:
            transform = transform.translatedBy(x: rect.size.width, y: rect.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
        case .downMirrored:
            transform = transform.translatedBy(x: 0.0, y: rect.size.height)
            transform = transform.scaledBy(x: 1.0, y: -1.0)
        case .left:
            bounds = swapWithAndHeight(bounds)
            transform = transform.translatedBy(x: 0.0, y: rect.size.width)
            transform = transform.rotated(by: 3.0 * CGFloat(M_PI) / 2.0)
        case .leftMirrored:
            bounds = swapWithAndHeight(bounds)
            transform = transform.translatedBy(x: rect.size.height, y: rect.size.width)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            transform = transform.rotated(by: 3.0 * CGFloat(M_PI) / 2.0)
        case .right:
            bounds  = swapWithAndHeight(bounds)
            transform = transform.translatedBy(x: rect.size.height, y: 0.0)
            transform = transform.rotated(by: CGFloat(M_PI) / 2.0)
        case .rightMirrored:
            bounds = swapWithAndHeight(bounds)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            transform = transform.rotated(by: CGFloat(M_PI) / 2.0)
        }
        
        UIGraphicsBeginImageContext(bounds.size)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        // 获取上下文
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        switch orient {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.scaleBy(x: -1.0, y: 1.0)
            context.translateBy(x: -rect.size.height, y: 0.0)
        default:
            context.scaleBy(x: 1.0, y: -1.0)
            context.translateBy(x: 0.0, y: -rect.size.height)
        }
        context.concatenate(transform)
        context.draw(cgImage!, in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image
    }
    
    // MARK: - 垂直翻转
    public var wb_flipVertical: UIImage? {
        return wb_rotateWithOrient(.downMirrored)
    }
    
    // MARK: - 水平翻转
    public var wb_filpHorizontal: UIImage? {
        return wb_rotateWithOrient(.upMirrored)
    }
    
    // MARK: - 截取当前image对象rect区域内的图像
    @discardableResult
    public func wb_subImageWithRect(_ rect:CGRect) -> UIImage? {
        guard let imageRef = cgImage!.cropping(to: rect) else{
            return nil
        }
        return UIImage(cgImage: imageRef)
    }
    
    // MARK: - 压缩图片至指定尺寸
    @discardableResult
    public func wb_rescaleImageToSize(_ size:CGSize) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // MARK : - 压缩图片至指定像素
    @discardableResult
    public func wb_rescaleImageToPx(_ toPx:CGFloat) -> UIImage? {
        var newSize = size
        if newSize.width <= toPx && newSize.height <= toPx {
            return self
        }
        let scale = newSize.width / newSize.height
        if newSize.width >  newSize.height {
            newSize.width = toPx
            newSize.height = newSize.width / scale
        }
        else{
            newSize.height = toPx
            newSize.width = newSize.height * scale
        }
        return wb_rescaleImageToSize(newSize)
    }
    
    // MARK: - 指定大小生成一个平铺的图片
    @discardableResult
    public func wb_getTiledImageWithSize(_ size:CGSize) -> UIImage? {
        let tempView = UIView()
        tempView.bounds = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        tempView.backgroundColor = UIColor(patternImage: self)
        
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        tempView.layer.render(in: context!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // MARK: - UIView转化为UIImage
    @discardableResult
    public class func wb_imageFromView(_ view:UIView) -> UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        view.layer.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - 两张图片生成一张图片
    @discardableResult
    public class func wb_mergeImage(_ firstImage:UIImage, secondImage lastImage:UIImage) -> UIImage? {
        let firstImageRef = firstImage.cgImage!
        let firstWidth = CGFloat(firstImageRef.width)
        let firstHeight = CGFloat(firstImageRef.height)
        let secondImageRef = lastImage.cgImage!
        let secondWidth = CGFloat(secondImageRef.width)
        let secondHeight = CGFloat(secondImageRef.height)
        let mergedSize = CGSize(width: max(firstWidth, secondWidth), height: max(firstHeight, secondHeight))
        UIGraphicsBeginImageContext(mergedSize)
        firstImage.draw(in: CGRect(x: 0.0, y: 0.0, width: firstWidth, height: firstHeight))
        lastImage.draw(in: CGRect(x: 0.0, y: 0.0, width: secondWidth, height: secondHeight))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    // MARK: - Private
    private var imageHasAlpha: Bool {
        
        let alpha = cgImage!.alphaInfo
        return alpha == .first || alpha == .last || alpha == .premultipliedFirst || alpha == .premultipliedLast
    }
    
    // 交换宽和高
    private func swapWithAndHeight(_ rect:CGRect) -> CGRect {
        var copyRect = rect
        let swap = copyRect.size.width
        copyRect.size.width = copyRect.size.height
        copyRect.size.height = swap
        return copyRect
    }
}
