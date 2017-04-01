//
//  PayManager.swift
//  HSDashedLine
//
//  Created by zwb on 17/2/7.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit


// MARK: - 支付结果状态码

public enum WB_Pay_ErrorCode : Int{
    case success
    case failure
    case cancle
}

// MARK: - 合并支付类( 集成支付宝与微信支付 )

// 需要微信支付 需要添加的库有:
// libz.tbd, libsqlite3.0.tbd, libc++.tbd, SystemConfiguration.framework, Security.framework, CoreTelephony.framework, CFNetwork.framework

// 支持支付宝支付，需要添加的库有:
// libc++.tbd, libz.tbd, SystemConfiguration.framework, CoreTelephony.framework, QuartzCore.framework, CoreText.framework, CoreGraphics.framework, UIKit.framework, Foundation.framework, CFNetwork.framework, CoreMotion.framework

public class PayManager: NSObject, WXApiDelegate {

    public struct WB_payKey {
        
        /// 此处是info.plist中的 URL Types 的Identifier, 必须保持一致
        public static let wechatURLName = "weixin"
        public static let alipayURLName = "alipay"
    }
    
    /// 对支付结果进行回调
    public typealias completeCallBack=(_ errorCode:WB_Pay_ErrorCode, _ errorString:String) -> Void
    
    private var callBack: completeCallBack?  // 缓存回调
    private var appSchemeDict = [String: String]()  // 缓存appScheme
    
    // 单例
    public static let shared = PayManager()
    
    /// 处理跳转的URL，回到应用，在AppDelegate中实现
    public func wb_handleURL(_ url:URL?) -> Bool {
        guard let url = url else {
            WB_Log("请求支付的url地址不符合要求!")
            return false
        }
        if url.host == "pay" {
            // 微信支付
            return WXApi.handleOpen(url, delegate: self)
            
        }else if url.host == "safepay" {
            // 支付宝支付
            // 跳转到支付宝钱包支付，处理支付结果(在app被杀时，通过该方法获取支付结果)
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { [unowned self] (resultDict) in
                if let resultDict = resultDict {
                    WB_Log("app已被kill,钱包支付结果为___:\(resultDict)")
                    let resultStatus = resultDict["resultStatus"] as? String ?? ""
                    var errorStr = resultDict["memo"] as? String ?? ""
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
                    if let closure = self.callBack {
                        closure(errorCode, errorStr)
                    }
                }
            })
            
            // 授权跳转支付宝钱包支付，处理支付结果
            AlipaySDK.defaultService().processAuth_V2Result(url, standbyCallback: { (resultDict) in
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
            })
            return true
        }
        return false
    }
    
    ///  注册App，需要在 didFinishLaunchingWithOptions 中调用
    public func wb_registerApp() {
        guard let dictionary = Bundle.main.infoDictionary else {
            WB_Log("info.plist 不存在")
            return
        }
        let urlTypes = dictionary["CFBundleURLTypes"] as? NSArray ?? []
        if urlTypes.count == 0{
            WB_Log("请在Info.plist 中添加支付的URL Type!")
            return
        }
        for urlTypeDict in urlTypes {
            guard let urlDictionary = urlTypeDict as? NSDictionary else { continue }
            let urlName = urlDictionary.object(forKey: "CFBundleURLName") as? String ?? ""
            let urlSchemes = urlDictionary.object(forKey: "CFBundleURLSchemes") as? NSArray ?? []
            if urlSchemes.count == 0{
                // 添加的URL Type中信息不完善!
                WB_Log("请在Info.plist的URL Type中添加\(urlName)对应的URL Scheme!")
                return
            }
            // 一个URLName对应一个
            let urlScheme = urlSchemes.lastObject as? String ?? ""
            if urlName == WB_payKey.wechatURLName {
                appSchemeDict.updateValue(urlScheme, forKey: WB_payKey.wechatURLName)
                // 注册微信
                WXApi.registerApp(urlScheme)
            }else if urlName == WB_payKey.alipayURLName {
                // 保存支付宝scheme,用以发起支付
                appSchemeDict.updateValue(urlScheme, forKey: WB_payKey.alipayURLName)
            }else{
                // 若还有其他支付，可在此绑定
                
            }
        }
    }
    
    /// 发起支付功能,  当orderMsg传入为字符串时，对应的为支付宝支付，如果传入的是PayReq对象，
    /// 则跳转到 微信支付 ,且orderMsg不能为nil, rollBack为支付结果回调
    public func wb_payWithOrderMsg(_ orderMsg:Any?, callBack rollBack: completeCallBack?) {
        guard let orderMsg = orderMsg else {
            WB_Log("订单信息不能为空!")
            return
        }
        // 缓存block
        self.callBack = rollBack
        // 发起支付
        if orderMsg is PayReq {
            // 微信支付
            WXApi.send(orderMsg as! PayReq)
        }else if orderMsg is String {
            let msg = orderMsg as! String
            // 支付宝支付
            if msg.isEmpty {
                WB_Log("支付宝订单信息不能为空!")
                return
            }
            
            guard let alipayShceme = appSchemeDict[WB_payKey.alipayURLName],  !alipayShceme.isEmpty else {
                WB_Log("请在Info.plist的URL Type中添加\(WB_payKey.alipayURLName)对应的URL Scheme!")
                return
            }
            AlipaySDK.defaultService().payOrder(msg, fromScheme: alipayShceme, callback: { [unowned self] (resultDic) in
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
                    if let closure = self.callBack {
                        closure(errorCode, errorStr)
                    }
                }
            })
        }
    }
    
    // MARK: -  WXApiDelegate
    public func onResp(_ resp: BaseResp!) {
        // 判断支付类型
        if resp is PayResp {
            // 支付回调
            var errorCode:WB_Pay_ErrorCode = .success
            var errorString = resp.errStr
            switch resp.errCode {
            case 0:
                errorCode = .success
                errorString = "订单支付成功!"
            case -1:
                errorCode = .failure
                errorString = resp.errStr
            case -2:
                errorCode = .cancle
                errorString = "用户取消支付"
            default:
                errorCode = .failure
                errorString = resp.errStr
            }
            // 对支付结果进行回调,实际结果需从服务端去微信服务器查询
            if let closure = self.callBack {
                closure(errorCode, errorString ?? "")
            }
        }
    }
}
