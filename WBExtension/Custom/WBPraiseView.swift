//
//  WBPraiseView.swift
//  Angebot
//
//  Created by zwb on 17/2/23.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit

// MARK: - 使用帧动画实现直播点赞动画效果

public class WBPraiseView: UIView {

    private let PI:CGFloat = CGFloat(M_PI)

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUserInterface()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initUserInterface()
    }
    
    public override func draw(_ rect: CGRect) {
        
//        drawHertInRect(rect)
        
        drawImageInRect(rect)
    }
    
    /// 实现动画效果
    public func wb_animationInView(_ view:UIView) {
        
        let totalAnimationDuration:TimeInterval = 6.0
        let heartSize = bounds.width
        let heartCenterX = center.x
        let viewHeight = view.bounds.height
        
        // Pre-Animation setup
        transform = CGAffineTransform(scaleX: 0, y: 0)
        alpha = 0.0
        
        // Bloom
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: { 
            self.transform = .identity
            self.alpha = 0.9
        }, completion: nil)
        
        let i:CGFloat = CGFloat(arc4random_uniform(2))
        let rotationDirection = 1 - (2*i) // -1 or 1
        let rotationFraction:CGFloat = CGFloat(arc4random_uniform(10))
        UIView.animate(withDuration: totalAnimationDuration) { 
            self.transform = CGAffineTransform(rotationAngle: rotationDirection * self.PI / (16 + rotationFraction * 0.2))
        }
        
        let heartTravelPath = UIBezierPath()
        heartTravelPath.move(to: center)
        
        // random end point
        let endPoint = CGPoint(x: heartCenterX + rotationDirection * CGFloat(arc4random_uniform(2*UInt32(heartSize))), y: viewHeight/3.0*2.0 + CGFloat(arc4random_uniform(UInt32(viewHeight)/4)))
        
        // random Control Points
        let j:CGFloat = CGFloat(arc4random_uniform(2))
        let traveDirection = 1 - (2*j) // -1 or 1
        
        
        // randomize x and y for control points
        let xDelta = heartSize/2.0 + CGFloat(arc4random_uniform(2*UInt32(heartSize))) * traveDirection
        let yDelta = max(endPoint.y, max(CGFloat(arc4random_uniform(8*UInt32(heartSize))), heartSize))
        let controlPoint1 = CGPoint(x: heartCenterX + xDelta, y: viewHeight - yDelta)
        let controlPoint2 = CGPoint(x: heartCenterX - 2*xDelta, y: yDelta)
        
        heartTravelPath.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "position")
        keyFrameAnimation.path = heartTravelPath.cgPath
        keyFrameAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        keyFrameAnimation.duration = totalAnimationDuration + TimeInterval(endPoint.y / viewHeight)
        layer.add(keyFrameAnimation, forKey: "positionOnPath")
        
        // Alpha & remove from superview
        UIView.animate(withDuration: totalAnimationDuration, animations: { 
            self.alpha = 0.0
        }) { (finished) in
            self.removeFromSuperview()
        }
        
    }
    
    // MARK: - Private
    
    private func initUserInterface() {
        
        backgroundColor = .clear
        layer.anchorPoint = CGPoint(x: 0.5, y: 1)
    }
    
    ///  这里是实现自己自定义图片的效果
    private func drawImageInRect(_ rect:CGRect) {
        
        let image=UIImage(named: "top_click")!
        image.draw(in: rect)
    }
    
    ///   这里是实现心形的图画效果
    private func drawHertInRect(_ rect:CGRect) {
        
        UIColor.white.setStroke()
        // 取一个随机颜色
        let randColor = UIColor(red: CGFloat(arc4random_uniform(255)), green: CGFloat(arc4random_uniform(255)), blue: CGFloat(arc4random_uniform(255)), alpha: 1.0)
        randColor.setFill()
        
        let drawingPadding:CGFloat = 4.0
        let curveRadius:CGFloat = floor((rect.width - 2*drawingPadding) / 4.0)
        
        // Create path
        let heartPath = UIBezierPath()
        
        // Start at bottom heart tip
        let tipLocation = CGPoint(x: floor(rect.width / 2.0), y: rect.height - drawingPadding)
        heartPath.move(to: tipLocation)
        
        // Move to top left start of curve
        let topLeftCurveStart = CGPoint(x: drawingPadding, y: floor(rect.height / 2.4))
        
        heartPath.addQuadCurve(to: topLeftCurveStart, controlPoint: CGPoint(x: topLeftCurveStart.x, y: topLeftCurveStart.y + curveRadius))
        
        // Create top left curve
        heartPath.addArc(withCenter: CGPoint(x: topLeftCurveStart.x + curveRadius, y: topLeftCurveStart.y), radius: curveRadius, startAngle: PI, endAngle: 0, clockwise: true)
        
        // Create top right curve
        let topRightCurveStart = CGPoint(x: topLeftCurveStart.x + 2*curveRadius, y: topLeftCurveStart.y)
        heartPath.addArc(withCenter: CGPoint(x: topRightCurveStart.x + curveRadius, y: topRightCurveStart.y), radius: curveRadius, startAngle: PI, endAngle: 0, clockwise: true)
        
        // Final curve to bottom heart tip
        let topRightCurveEnd = CGPoint(x: topLeftCurveStart.x + 4*curveRadius, y: topRightCurveStart.y)
        heartPath.addQuadCurve(to: tipLocation, controlPoint: CGPoint(x: topRightCurveEnd.x, y: topRightCurveEnd.y + curveRadius))
        
        heartPath.fill()
        
        heartPath.lineWidth = 1.0
        heartPath.lineCapStyle = .round
        heartPath.lineJoinStyle = .round
        heartPath.stroke()
    }

}
