//
//  WBPraiseEmitterView.swift
//  Angebot
//
//  Created by zwb on 17/2/22.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit

// MARK: -  粒子效果实现直播点赞动画效果

public class WBPraiseEmitterView: UIView {
    
    public var isShow:Bool!=false  // 记录是否还在显示

    private let emitter:CAEmitterLayer!={
        let emitte=CAEmitterLayer()
        return emitte
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initInterface()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initInterface()
    }
    
    private func initInterface() {
        
        emitter.frame = bounds
        emitter.birthRate = 2
        emitter.emitterShape = kCAEmitterLayerLine
        emitter.emitterPosition = CGPoint(x: bounds.size.width/2, y: bounds.size.height)
        emitter.emitterSize = bounds.size
        emitter.emitterCells = [getEmitterCell(UIImage(named: "top_click")!.cgImage!)]
        layer.addSublayer(emitter)
        
        isShow=true
        
        // 延时2s后不再生成
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            
            self!.emitter.birthRate = 0
        }
        
        // 延时4s后移除
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            
            self!.isShow=false
            self!.removeFromSuperview()
        }
    }
    
    private func getEmitterCell(_ image:CGImage) -> CAEmitterCell{
        
        let emitterCell = CAEmitterCell()
        emitterCell.contents = image
        emitterCell.lifetime = 2
        emitterCell.birthRate = 0.5
        
        emitterCell.yAcceleration = -10.0
        emitterCell.xAcceleration = 0
        
        emitterCell.velocity = 5.0
        emitterCell.velocityRange = 20
        
        emitterCell.emissionLatitude = 0
        emitterCell.emissionRange = CGFloat(M_PI_4)
        
        emitterCell.scale = 0.5
        emitterCell.scaleRange = 0.1
        emitterCell.scaleSpeed = -0.01
        
        emitterCell.alphaRange = 0.85
        emitterCell.alphaSpeed = -0.15
        
        return emitterCell
    }

}
