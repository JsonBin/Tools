//
//  ViewControllerExtension.swift
//  HSDashedLine
//
//  Created by zwb on 17/2/7.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

public extension UIViewController {
    
    public typealias actionBlock = (UIAlertAction) -> Void
    
    
    // MARK: - 系统功能 Photo and Library and Location
    
    /**
     检查设备的相机权限
     
     - returns: 可否使用
     */
    public var checkCamera: Bool {
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            WB_Log("设备不支持拍照的功能")
            return false
        }
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        // 相机权限关闭
        if status == .denied || status == .restricted{
            guard let dictionary = Bundle.main.infoDictionary, let appname = dictionary["CFBundleDisplayName"] as? String else {
                WB_Log("info.plist不存在或app名字还未设置!")
                return false
            }
            let str = String(format: "请在设备的\"设置-隐私-相机\"选项中允许 '%@' 访问您的相机", appname)
            doubleDefaultAlert(message: str, defaultActionTitle: "设置", defaultHandler: { (action) in
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url){
                        if #available(iOS 10.0, *){
                            UIApplication.shared.open(url)
                        }
                        else{
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            })
            return false
        }
        return true
    }
    
    /**
     检查设备的相册使用权限
     
     - returns: 可否使用
     */
    public var checkLibrary: Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .denied || status == .restricted{
            guard let dictionary = Bundle.main.infoDictionary, let appname = dictionary["CFBundleDisplayName"] as? String else {
                WB_Log("info.plist不存在或app名字还未设置!")
                return false
            }
            let str = String(format: "请在设备的\"设置-隐私-照片\"选项中允许 '%@' 访问您的相册", appname)
            doubleDefaultAlert(message: str, defaultActionTitle: "设置", defaultHandler: { (action) in
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url){
                        if #available(iOS 10.0, *){
                            UIApplication.shared.open(url)
                        }
                        else{
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            })
            return false
        }
        return true
    }
    
    /**
     检查设备的定位使用权限
     
     - returns: 可否使用
     */
    public var checkLocation: Bool {
        let status = CLLocationManager.authorizationStatus()
        if status == .denied || status == .restricted{
            guard let dictionary = Bundle.main.infoDictionary, let appname = dictionary["CFBundleDisplayName"] as? String else {
                WB_Log("info.plist不存在或app名字还未设置!")
                return false
            }
            let str = String(format: "请在设备的\"设置-隐私-定位\"选项中允许 '%@' 访问您的定位服务", appname)
            doubleDefaultAlert(message: str, defaultActionTitle: "设置", defaultHandler: { (action) in
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url){
                        if #available(iOS 10.0, *){
                            UIApplication.shared.open(url)
                        }
                        else{
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            })
            return false
        }
        return true
    }
    
    
    // MARK: - AlertView adn AlertSheet
    
    /**
     一个确定按钮的提示
     
     - parameter message: 提示内容
     - parameter action:  执行内容
     
     */
    public func signalAlert(_ title:String? = "提示", message showMsg:String, actionTitle actitle:String = "确定", handler action:actionBlock? = nil) {
        let alertController = UIAlertController(title: title,
                                              message: showMsg,
                                              preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: actitle,
                                                style: .default,
                                                handler: action))
        present(alertController, animated: true, completion: nil)
    }
    
    /**
     一个取消按钮，一个其他按钮（默认色）
     
     - parameter title:   其他按钮标题
     - parameter message: 提示信息
     
     */
    public func doubleDefaultAlert(_ title:String? = "提示", message showMsg:String, cancleTitle cletitle:String = "取消", defaultActionTitle dattitle:String = "确定", defaultHandler action:actionBlock? = nil) {
        let alertController = UIAlertController(title: title,
                                              message: showMsg,
                                              preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: cletitle,
                                                style: .cancel,
                                                handler: nil))
        alertController.addAction(UIAlertAction(title: dattitle,
                                                style: .default,
                                                handler: action))
        present(alertController, animated: true, completion: nil)
    }
    
    /**
     一个取消按钮，一个其他按钮（红色）
     
     - parameter title:   其他按钮标题
     - parameter message: 提示信息
     - parameter action:  其他按钮事件
     
     */
    public func doubleRedAlert(_ title:String? = "提示", message showMsg:String, cancleTitle cletitle:String = "取消", defaultActionTitle dattitle:String = "确定", defaultHandler action:actionBlock? = nil) {
        let alertController = UIAlertController(title: title,
                                              message: showMsg,
                                              preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: cletitle,
                                                style: .cancel,
                                                handler: nil))
        alertController.addAction(UIAlertAction(title: dattitle,
                                                style: .destructive,
                                                handler: action))
        present(alertController, animated: true, completion: nil)
    }
    
    /**
     自定义系统alertSheet,最多可设置两个alert
     
     - parameter title:   其他按钮标题
     - parameter message: 提示信息
     
     */
    public func cancleAlertSheet(_ title:String? = nil, message showMsg:String? = nil, firstTitle fsttitle:String? = nil, sencondTitle scdTitle:String? = nil, cancleTitle cleTitle:String? = nil, firstHandler fstAction:actionBlock? = nil, sencondHandler scdAction:actionBlock? = nil) {
        let alertController = UIAlertController(title: title,
                                              message: showMsg,
                                              preferredStyle: .actionSheet)
        if let fsttitle = fsttitle {
            alertController.addAction(UIAlertAction(title: fsttitle,
                                                    style: .default,
                                                    handler: fstAction))
        }
        if let scdTitle = scdTitle {
            alertController.addAction(UIAlertAction(title: scdTitle,
                                                    style: .default,
                                                    handler: scdAction))
        }
        if let cleTitle = cleTitle {
            alertController.addAction(UIAlertAction(title: cleTitle,
                                                    style: .cancel,
                                                    handler: nil))
        }
        present(alertController, animated: true, completion: nil)
    }
}
