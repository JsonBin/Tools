//
//  ColorExtension.swift
//  HSDashedLine
//
//  Created by zwb on 17/2/7.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit


public extension UIColor{
    
    @discardableResult
    public class func wb_rgb(_ red:CGFloat, g green:CGFloat, b blue:CGFloat, a alpha:CGFloat = 1.0) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
}
