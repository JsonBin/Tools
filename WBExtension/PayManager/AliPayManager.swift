//
//  AliPayManager.swift
//  WBExtension
//
//  Created by zwb on 17/2/8.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit


// MARK: - 单独支付类( 单独集成支付宝 )

public class AliPayManager: NSObject {
    
    private struct WB_payKey {
        
        /// 设置支付宝默认的URL Types的Identifier 
        /// 此处是info.plist中的 URL Types 的Identifier, 必须保持一致
        public static let alipayURLName = PayManager.WB_payKey.alipayURLName
    }
    
    ///  独立支付宝支付结果进行回调
    public typealias alipayBlock = (_ dictionary:[AnyHashable: Any]) -> Void
    
    public static let shared = AliPayManager()
    
    private var wb_callBack: PayManager.completeCallBack?
    
    /// 支付宝授权支付，需在AppDelegate中实现
    
    public func wb_handlerURL(_ url:URL?) -> Bool {
        guard let url = url else {
            WB_Log("支付宝支付的url不能为nil!")
            return false
        }
        
        // 支付跳转支付宝钱包支付，处理支付结果(在app被杀时，通过该方法获取支付结果)
        AlipaySDK.defaultService().processOrder(withPaymentResult: url) { [unowned self] (resultDict) in
            if let resultDict = resultDict {
                WB_Log("app已被kill,钱包支付结果为___:\(resultDict)")
                let resultStatus=resultDict["resultStatus"] as? String ?? ""
                var errorStr=resultDict["memo"] as? String ?? ""
                var errorCode:WB_Pay_ErrorCode = .success
                switch resultStatus {
                case "9000":
                    // 成功
                    errorCode = .success
                    errorStr = "订单支付成功!"
                case "6001":
                    // 用户取消
                    errorCode = .cancle
                    errorStr = "用户取消支付！"
                default:
                    // 失败
                    errorCode = .failure
                }
                // 对支付结果进行回调,实际结果需从服务端去支付宝服务器查询
                if let closure = self.wb_callBack {
                    closure(errorCode, errorStr)
                }
            }
        }
        
        // 授权跳转支付宝钱包支付，处理支付结果
        AlipaySDK.defaultService().processAuth_V2Result(url) { (resultDict) in
            if let resultDict = resultDict {
                WB_Log("支付宝授权支付结果为___:\(resultDict)")
                // 解析auth code
                let result = resultDict["result"] as? String ?? ""
                var authCode: String = ""
                if !result.isEmpty {
                    let resultStrArr = result.components(separatedBy: "&")
                    for subResult in resultStrArr {
                        if subResult.characters.count > 10 && subResult.hasPrefix("auth_code=") {
                            authCode = subResult.substring(from: subResult.index(subResult.startIndex, offsetBy: 10))
                            break
                        }
                    }
                }
                WB_Log("支付宝授权支付授权结果为___:\(authCode)")
            }
        }
        return true
    }
    
    /// 可在任意位置，发起支付
    /// 如果没有传入scheme,那么通过默认的支付宝URL Types名字<WB_payKey.alipayURLName>去Info.plist中搜索相对应的Identifier
    /// 并可对支付结果进行回调
    public func wb_alipayWithOrderMsg(_ orderMsg:String?, appScheme scheme:String?, callBack rollBack: PayManager.completeCallBack?) {
        guard let orderMsg = orderMsg else {
            WB_Log("支付宝支付的订单信息不能为nil!")
            return
        }
        var alipayScheme: String = ""
        if let scheme = scheme {
            alipayScheme = scheme
        }else{
            guard let dictionary = Bundle.main.infoDictionary else {
                WB_Log("info.plist 不存在")
                return
            }
            let urlTypes = dictionary["CFBundleURLTypes"] as? NSArray ?? []
            if urlTypes.count == 0{
                WB_Log("请在Info.plist 中添加支付宝的URL Type!")
                return
            }
            for urlTypeDict in urlTypes{
                guard let urlDictionary = urlTypeDict as? NSDictionary else { continue }
                let urlName = urlDictionary.object(forKey: "CFBundleURLName") as? String ?? ""
                if urlName == WB_payKey.alipayURLName {
                    let urlSchemes = urlDictionary.object(forKey: "CFBundleURLSchemes") as? NSArray ?? []
                    if urlSchemes.count == 0{
                        // 添加的URL Type中信息不完善!
                        WB_Log("请在Info.plist的URL Type中添加\(urlName)对应的URL Scheme!")
                        return
                    }
                    // 一个URLName对应一个
                    alipayScheme = urlSchemes.lastObject as? String ?? ""
                    break
                }
            }
        }
        if alipayScheme.isEmpty {
            WB_Log("支付宝支付的scheme不能为nil并且需要和info.plist的配置保持一致!")
            return
        }
        
        self.wb_callBack = rollBack
        AlipaySDK.defaultService().payOrder(orderMsg, fromScheme: alipayScheme) { (resultDic) in
            // 处理支付结果
            if let resultDic = resultDic {
                let resultStatus = resultDic["resultStatus"] as? String ?? ""
                var errorStr = resultDic["memo"] as? String ?? ""
                var errorCode:WB_Pay_ErrorCode = .success
                switch resultStatus {
                case "9000":
                    // 成功
                    errorCode = .success
                    errorStr = "订单支付成功!"
                case "6001":
                    // 用户取消
                    errorCode = .cancle
                    errorStr = "用户取消支付！"
                default:
                    // 失败
                    errorCode = .failure
                }
                // 对支付结果进行回调,实际结果需从服务端去支付宝服务器查询
                if let closure = rollBack {
                    closure(errorCode, errorStr)
                }
            }
        }
    }
}
