//
//  WxPayManager.swift
//  WBExtension
//
//  Created by zwb on 17/2/8.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit


// MARK: - 单独支付类( 单独集成微信支付 )

public class WxPayManager: NSObject, WXApiDelegate {
    
    private struct WB_payKey {
        
        /// 设置微信默认的URL Types的Identifier
        /// 此处是info.plist中的 URL Types 的Identifier, 必须保持一致
        public static let wechatURLName = PayManager.WB_payKey.wechatURLName
    }
    
    ///  独立支付宝支付结果进行回调
    public typealias wxpayBlock = (_ dictionary:[AnyHashable: Any]) -> Void
    
    public static let shared = WxPayManager()
    
    private var wb_callBack: PayManager.completeCallBack?
    
    /// 微信授权支付，需在AppDelegate中实现
    public func wb_handlerURL(_ url:URL?) -> Bool{
        guard let url = url else {
            WB_Log("请求支付的url地址不符合要求")
            return false
        }
        return WXApi.handleOpen(url, delegate: self)
    }
    
    /// 注册App，需要在 didFinishLaunchingWithOptions 中调用
    /// 如果没有传入scheme,那么通过默认的微信URL Types名字<WB_payKey.wechatURLName>去Info.plist中搜索相对应的Identifier
    public func wb_registerApp(_ scheme:String?) {
        var wxScheme:String = ""
        if let scheme = scheme {
            wxScheme = scheme
        }else{
            guard let dictionary = Bundle.main.infoDictionary else {
                WB_Log("info.plist 不存在")
                return
            }
            let urlTypes = dictionary["CFBundleURLTypes"] as? NSArray ?? []
            if urlTypes.count == 0{
                WB_Log("请在Info.plist 中添加微信的URL Type!")
                return
            }
            for urlTypeDict in urlTypes{
                guard let urlDictionary = urlTypeDict as? NSDictionary else { continue }
                let urlName = urlDictionary.object(forKey: "CFBundleURLName") as? String ?? ""
                if urlName == WB_payKey.wechatURLName {
                    let urlSchemes = urlDictionary.object(forKey: "CFBundleURLSchemes") as? NSArray ?? []
                    if urlSchemes.count == 0 {
                        // 添加的URL Type中信息不完善!
                        WB_Log("请在Info.plist的URL Type中添加\(urlName)对应的URL Scheme!")
                        return
                    }
                    // 一个URLName对应一个
                    wxScheme = urlSchemes.lastObject as? String ?? ""
                    break
                }
            }
        }
        if wxScheme.isEmpty {
            WB_Log("微信的scheme不能为nil并且需要和info.plist的配置保持一致!")
            return
        }
        WXApi.registerApp(wxScheme)
    }
    
    /// 发起微信支付，并附带支付结果回调
    public func wb_wxPayWithPayReq(_ req:PayReq, callBack rollBack: PayManager.completeCallBack?) {
        // 存储回调
        self.wb_callBack = rollBack
        // 发起支付
        WXApi.send(req)
    }

    // MARK: - WXApiDelegate
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
            if let closure = self.wb_callBack {
                closure(errorCode, errorString ?? "")
            }
        }
    }
}
