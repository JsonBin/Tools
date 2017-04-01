//
//  Bundle+WBExtension.swift
//  WBExtension
//
//  Created by zwb on 17/3/10.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import Foundation

// MARK: - 延展刷新框架的Bundle

public extension Bundle {
    
    /// 获取Bundle路径
    public static var wb_refreshBundle: Bundle! {
        var refreshBundle: Bundle!
        if refreshBundle == nil{
            // 不适用main是为了适配1.0和0.x
            refreshBundle = Bundle(path: Bundle(for: RefreshView.classForCoder()).path(forResource: "WBRefresh", ofType: "bundle")!)
        }
        return refreshBundle
    }
    
    /// 获取下拉图片
    public static var wb_arrowImage: UIImage {
        var arrowImage: UIImage!
        if arrowImage == nil{
            arrowImage = UIImage(contentsOfFile: wb_refreshBundle.path(forResource: "arrow@2x", ofType: "png")!)?.withRenderingMode(.alwaysTemplate)
        }
        return arrowImage
    }
    
    public static func wb_localizedStringForKey(_ key:String, value valu:String? = nil) -> String {
        var bundle: Bundle!
        if bundle == nil{
            // 获取iOS的系统语言字符串
            var language = Locale.preferredLanguages.first!
            if language.hasPrefix("en"){
                language = "en"
            }else if language.hasPrefix("zh"){
                if language.range(of: "Hans") != nil{
                    language = "zh-Hans"  // 简体中文
                }else{  // zh-Hant/zh-HK/zh-TW
                    language = "zh-Hant"  // 繁体中文
                }
            }else{
                language = "en"
            }
            // 从WBRefresh.bundle中查找
            bundle = Bundle(path: wb_refreshBundle.path(forResource: language, ofType: "lproj")!)
        }
        let value = bundle.localizedString(forKey: key, value: valu, table: nil)
        return Bundle.main.localizedString(forKey: key, value: value, table: nil)
    }
}
