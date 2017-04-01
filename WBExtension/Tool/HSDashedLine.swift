//
//  HSDashedLine.swift
//  HSDashedLine
//
//  Created by zwb on 17/2/5.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit


// MARK: - 创建虚线

public class HSDashedLine: UIView {
    
    public static func wb_createDashedLineWithFrame(_ frame:CGRect, lineLength length:Int, lineSpace space :Int, lineColor color:UIColor = .lightGray) -> UIView{
        
        let dashedLine:HSDashedLine = super.init(frame: frame) as! HSDashedLine
        dashedLine.backgroundColor = .clear
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = dashedLine.bounds
        shapeLayer.position = CGPoint(x: dashedLine.frame.size.width/2, y: dashedLine.frame.size.height)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = dashedLine.frame.size.height
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [NSNumber(integerLiteral: length),NSNumber(integerLiteral: space)]
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: dashedLine.frame.size.width, y: 0))
        
        shapeLayer.path = path
        dashedLine.layer.addSublayer(shapeLayer)
        
        return dashedLine
    }
}

