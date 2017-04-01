//
//  TableViewExtension.swift
//  WBExtension
//
//  Created by zwb on 17/2/8.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit
import ImageIO

// MARK: - UITableView 无数据和无网络显示 (采用runtime添加属性)

///  用于系统的UITableView, 且未添加延展属性,重新自定义reloadData方法(如导入了MJRefresh就不适用),
///  若导入了MJRefresh后，需使用，则需按照此延展初始化时initialize()的最后一步按此方法处理
///  适用于 UITableView的style为plain的情况，同样也适用于style为grouped下的情况，但
///  style为grouped的时候，需实现 tableView(_:viewForHeaderInSection:) 和 tableView(_:viewForFooterInSection:)
///  的情况时，最好把背景设置为透明色。

extension UITableView {
    
    
    public struct imageViewClickBlock {
        
        public typealias clickOperation=()->Void
    }
    
    private struct wb_tableKey{
        
        public static let no_data_key=UnsafeRawPointer(bitPattern: "static_no_data_key".hashValue)
        public static let no_network_key=UnsafeRawPointer(bitPattern: "static_no_network_key".hashValue)
        public static let imageview_key=UnsafeRawPointer(bitPattern: "static_imageview_key".hashValue)
        public static let imageview_operation_key=UnsafeRawPointer(bitPattern: "static_imageview_operation_key".hashValue)
        public static let autocache_key=UnsafeRawPointer(bitPattern: "static_autocache_key".hashValue)
        public static let refresh_key=UnsafeRawPointer(bitPattern: "static_thirdRefresh_key".hashValue)
        
        public static var cache:String!  // 沙盒路径
        public static var memory_cache:NSCache<AnyObject, AnyObject>!   // 内存缓存
        public static var autoCache:Bool!
    }
    
    /// 是否开启自动缓存，会缓存到内存和沙盒 Default true.
    internal var wb_autoCache:Bool! {
        set{
            objc_setAssociatedObject(self, wb_tableKey.autocache_key, newValue, .OBJC_ASSOCIATION_ASSIGN)
            wb_tableKey.autoCache=newValue
        }
        get{
            guard let auto=objc_getAssociatedObject(self, wb_tableKey.autocache_key) else {
                return true
            }
            return auto as! Bool
        }
    }
    
    /// 没有数据时显示的图片,可以为本地图片或者网络图片URL，若为URL，则自动缓存
    internal var wb_noData_image:String! {
        set{
            guard let imagePath=newValue else {
                WB_Log("wb_noData_image不能为nil!")
                return
            }
            objc_setAssociatedObject(self, wb_tableKey.no_data_key, imagePath, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get{
            guard let path=objc_getAssociatedObject(self, wb_tableKey.no_data_key) else {
                WB_Log("还未设置无数据时需要显示的图片或URL!")
                return nil
            }
            return path as! String
        }
    }
    
    /// 没有网络时显示的图片,可以为本地图片或者网络图片URL，若为URL，则自动缓存
    internal var wb_noNetWork_image:String! {
        set{
            guard let imagePath=newValue else {
                WB_Log("wb_noNetWork_image不能为nil!")
                return
            }
            objc_setAssociatedObject(self, wb_tableKey.no_network_key, imagePath, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get{
            guard let path=objc_getAssociatedObject(self, wb_tableKey.no_network_key) else {
                WB_Log("还未设置无网络时需要显示的图片或URL!")
                return nil
            }
            return path as! String
        }
    }
    
    
    private var wbImageView:UIImageView! {
        set{
            objc_setAssociatedObject(self, wb_tableKey.imageview_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            guard let imageVe=objc_getAssociatedObject(self, wb_tableKey.imageview_key) else {
                // 添加到wrapperView,tableView的y不会下移导航栏高度,wrapperView会偏移
                let wrapperView=value(forKey: "wrapperView") as! UIView
                let imageView=UIImageView()
                imageView.isUserInteractionEnabled=true
                // 添加点击事件
                let tapGes=UITapGestureRecognizer(target: self,
                                                  action: #selector(imageViewClickToOperate(_:)))
                imageView.addGestureRecognizer(tapGes)
                self.wbImageView=imageView
                // 布局frame
                updateImageViewFrame()
                
                wrapperView.addSubview(imageView)
                wrapperView.bringSubview(toFront: imageView)
                return imageView
            }
            return imageVe as! UIImageView
        }
    }
    private var clickBlock:imageViewClickBlock.clickOperation! {
        set{
            guard let closesure=newValue else {
                return
            }
            objc_setAssociatedObject(self, wb_tableKey.imageview_operation_key, closesure, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get{
            guard let block=objc_getAssociatedObject(self, wb_tableKey.imageview_operation_key) else {
                return nil
            }
            return block as! imageViewClickBlock.clickOperation
        }
    }
    
    /// 延展初始化方法，此方法类似于OC中的+(load) 方法，在调用时就会调用，
    /// 在此，为了初始化数据，因此，此方法只会调用一次。若想在MJRefresh中
    /// 适用此延展，则需按照最后一步操作.
    override open class func initialize() {
        
        {
            wb_tableKey.memory_cache = NSCache()
            
            // 设置最大成本数,超过自动清空
            wb_tableKey.memory_cache.totalCostLimit = 10
            
            wb_tableKey.autoCache = true
            
            // 缓存文件路径
            let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last
            wb_tableKey.cache = path?.appending("wb_cache")
            let isDir = UnsafeMutablePointer<ObjCBool>(bitPattern: 0)
            let isExists = FileManager.default.fileExists(atPath: wb_tableKey.cache, isDirectory: isDir)
            if !isExists || !(isDir != nil) {
                do{
                    try FileManager.default.createDirectory(atPath: wb_tableKey.cache, withIntermediateDirectories: true, attributes: nil)
                }catch {
                    WB_Log("创建缓存目录时失败!")
                }
            }
            
            /// 收到内存警告时，清空缓存
            /// 此方法还有待解决，在swift的extension中不支持deinit方法，因此注册了该通知之后
            /// 不能移除该通知方法，除非在每一个调用了UITableView的类中手动添加释放通知的方法.
            NotificationCenter.default.addObserver(self, selector: #selector(wb_celarMemoryWarning), name:NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
            
            
            /// 这里是为了判断响应第三方是否已经交换了UITableView的reloadData()方法
//            if class_respondsToSelector(classForCoder(), #selector(mj_reloadData)){
//                
//                /// 为了适配MJRefresh的方法，在此前需要在 UIScrollView+MJRefresh.h 头文件中加入一个声明
//                /// 暴露出自定义方法.添加如下:
//                /// @interface UITableView (MJRefresh)
//                
//                /// - (void)mj_reloadData;
//                
//                /// @end
//                /// 重新引导定义方法
//                wb_methodSwizzlingWithOriginalSelector(#selector(mj_reloadData), bySwizzledSelector: #selector(wb_reloadData))
//            }else{
            
                // 交换方法
                wb_methodSwizzlingWithOriginalSelector(#selector(reloadData), bySwizzledSelector: #selector(wb_reloadData))
//            }
        }()
        
    }
    
    // MARK: - Public
    public func wb_clearCache() {
        wb_clearMemoryCache()
        wb_clearDiskCache()
    }
    
    public func wb_imageViewClickOperation(_ click:imageViewClickBlock.clickOperation!){
        if click != nil{
            clickBlock=click
        }
    }
    
    // MARK: - reload
    
    @objc private func wb_reloadData() {
        // 首先判断网络状态
        if !checkNoNetWork {
            setImage(wb_noNetWork_image)
            wbImageView.isHidden=false
            separatorStyle = .none
            showOrHidde(true)
        }else{
            // 检查数据是否为空
            if checkNoData {
                wbImageView.isHidden=false
                setImage(wb_noData_image)
                separatorStyle = .none
                // 如果有headerView和FooterView则隐藏
                showOrHidde(true)
            }else{
                wbImageView.isHidden=true
                separatorStyle = .singleLine
                // 如果有headerView和FooterView则显示
                showOrHidde(false)
            }
        }
        
        wb_reloadData()
    }
    
    /// 显示/隐藏 其他组件
    private func showOrHidde(_ show:Bool) {
        // 如果有headerView和FooterView则隐藏/显示
        if let headerView=self.tableHeaderView{
            headerView.isHidden=show
        }
        if let footerView=self.tableFooterView{
            footerView.isHidden=show
        }
        // tablview的sectionViews,如果有则全部隐藏/显示，如果没有返回
        let sections=self.numberOfSections
        if sections==0{
            return
        }
        if delegate==nil{
            return
        }
        for section in 0..<sections{
            if delegate!.responds(to: #selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:))){
                if let header=delegate!.tableView!(self, viewForHeaderInSection: section){
                    header.isHidden=show
                    let height=delegate!.tableView!(self, heightForHeaderInSection: section)
                    if height<0.1{
                        header.backgroundColor=UIColor.clear
                    }
                }
            }
            if delegate!.responds(to: #selector(UITableViewDelegate.tableView(_:viewForFooterInSection:))){
                if let footer=delegate!.tableView!(self, viewForFooterInSection: section){
                    footer.isHidden=show
                    let height=delegate!.tableView!(self, heightForFooterInSection: section)
                    if height<0.1{
                        footer.backgroundColor=UIColor.clear
                    }
                }
            }
        }
    }
    
    // MARK: - NetWork
    
    private var checkNoNetWork: Bool{
        
        var flag=false
        let statusBar=UIApplication.shared.value(forKeyPath: "statusBar") as! NSObject
        let foregroundView=statusBar.value(forKeyPath: "foregroundView") as! UIView
        let childrenViews=foregroundView.subviews
        // 获取网络返回码
        for view in childrenViews{
            if view.isKind(of: NSClassFromString("UIStatusBarDataNetworkItemView")!){
                //获取到状态栏,飞行模式和关闭移动网络都拿不到dataNetworkType；1 - 2G; 2 - 3G; 3 - 4G; 5 - WIFI
                let netType=view.value(forKeyPath: "dataNetworkType") as! NSNumber
                switch netType {
                case 0:
                    // 无网模式
                    flag=false
                default:
                    flag=true
                }
            }
        }
        return flag
    }
    
    private var checkNoData: Bool{
        
        var sections=1
        var row=0
        var isEmpty=true
        if dataSource!.responds(to: #selector(UITableViewDataSource.numberOfSections(in:))){
            sections=dataSource!.numberOfSections!(in: self)
        }
        for section in 0..<sections{
            if dataSource!.responds(to: #selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:))) {
                row=dataSource!.tableView(self, numberOfRowsInSection: section)
                if row != 0{
                    isEmpty=false
                    // 有数值就不为空
                    break
                }else{
                    isEmpty=true
                }
            }
        }
        return isEmpty
    }
    
    // MARK: - Private
    
    /// 清空沙盒缓存
    private func wb_clearDiskCache() {
        DispatchQueue.global().async {
            
            do{
                let contents=try FileManager.default.contentsOfDirectory(atPath: wb_tableKey.cache)
                
                for fileName in contents{
                    let path=wb_tableKey.cache.appending(fileName)
                    try FileManager.default.removeItem(atPath: path)
                }
            }catch{
                WB_Log("读取沙盒缓存或清除沙盒缓存时失败!")
            }
        }
    }
    
    /// 清空内存缓存
    @objc private func wb_celarMemoryWarning() {
        wb_clearMemoryCache()
        // 清空内存缓存并移除通知
        /*NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)*/
    }
    
    @objc private func wb_clearMemoryCache() {
        wb_tableKey.memory_cache.removeAllObjects()
    }
    
    @objc private func imageViewClickToOperate(_ tapGesture:UIGestureRecognizer) {
        if clickBlock != nil{
            clickBlock()
        }
    }
    
    private static func wb_methodSwizzlingWithOriginalSelector(_ originalSelector:Selector, bySwizzledSelector swizzledSelector:Selector) {
        let originalMethod=class_getInstanceMethod(classForCoder(), originalSelector)
        let swizzledMethod=class_getInstanceMethod(classForCoder(), swizzledSelector)
        let didAddMethod=class_addMethod(classForCoder(), originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        if didAddMethod{
            class_replaceMethod(classForCoder(), swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        }else{
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    /// 布局frame
    private func updateImageViewFrame() {
        // 如果没有导航控制器，那么rect的y=0，如果有导航控制器，而且UINavigationBar是显示
        // 那么y = -64,如果有导航控制器，但UINavigationBar那么y = -20
        var concreteVc=NSClassFromString("NSConcreteValue")!.alloc()
        concreteVc=value(forKey: "visibleBounds") as AnyObject
        let rect=(concreteVc as! NSValue).cgRectValue
        
        /// 判断是否有tabBar显示
        /// 注意：分类中使用[UITabBar appearance] 和 [UINavigationBar appearance] 都不能获取对象，断点po提示<_UIAppearance:0x17025b000> <Customizable class: UITabBar> with invocations (null)>
        let currentVc=wb_viewController()
        guard let tabVc=currentVc.tabBarController else {
            wbImageView.frame=CGRect(x: rect.origin.x,
                                     y: 0,
                                     width: rect.size.width,
                                     height: rect.size.height+rect.origin.y)
            return
        }
        wbImageView.frame=CGRect(x: rect.origin.x,
                                 y: 0,
                                 width: rect.size.width,
                                 height: rect.size.height+rect.origin.y-( tabVc.tabBar.isHidden ? 0 : tabVc.tabBar.bounds.size.height))
    }
    
    /// 获取当前的控制器
    /// 摘自简书的文章：http://www.jianshu.com/p/dcd26e1ab30f
    private func wb_viewController() -> UIViewController{
        
        var vc=UIApplication.shared.keyWindow?.rootViewController
        // modal
        if vc?.presentedViewController != nil{
            if (vc!.presentedViewController?.isKind(of: UINavigationController.classForCoder()))!{
                let navVc=vc!.presentedViewController as! UINavigationController
                vc=navVc.visibleViewController
            }
            else if (vc!.presentedViewController?.isKind(of: UITabBarController.classForCoder()))!{
                let tabVc=vc?.presentedViewController as! UITabBarController
                if (tabVc.selectedViewController?.isKind(of: UINavigationController.classForCoder()))!{
                    let navVc=tabVc.selectedViewController as! UINavigationController
                    return navVc.visibleViewController!
                }else{
                    return tabVc.selectedViewController!
                }
            }else{
                vc=vc?.presentedViewController
            }
        }
            // push
        else{
            if (vc?.isKind(of: UITabBarController.classForCoder()))!{
                let tabVc=vc as! UITabBarController
                if (tabVc.selectedViewController?.isKind(of: UINavigationController.classForCoder()))!{
                    let navVc=tabVc.selectedViewController as! UINavigationController
                    return navVc.visibleViewController!
                }else{
                    return tabVc.selectedViewController!
                }
            }else if (vc?.isKind(of: UINavigationController.classForCoder()))!{
                let navVc=vc as! UINavigationController
                vc=navVc.visibleViewController
            }
        }
        return vc!
    }
    
    // MARK: - Image
    
    /// 设置wbImageView的image
    private func setImage(_ image:String!) {
        
        if image == nil {
            return
        }
        
        // 更新imageView的frame
        updateImageViewFrame()
        
        // 判断内存中是否存在
        guard let memory_cache_image=wb_tableKey.memory_cache.object(forKey: image as AnyObject) else {
            // 判断沙盒中是否存在,把名字中的/去掉,防止创建多个文件夹
            let imageName=image.replacingOccurrences(of: "/", with: "")
            let path=(wb_tableKey.cache as NSString).appendingPathComponent(imageName)
            guard let data=NSData(contentsOfFile: path) else {
                // 获取图片数据
                DispatchQueue(label: "com.asynqueue.tableViewExtension").async(execute: {
                    [unowned self] in
                    guard let imageData=NSData(contentsOf: URL(string: image)!) else{
                        // 从项目中获取的
                        if (image as NSString).range(of: ".gif").location != NSNotFound{
                            let local_gif_image=self.gifImageWithName(image)
                            DispatchQueue.main.async(execute: {
                                [unowned self] in
                                self.wbImageView.image=local_gif_image
                            })
                            if wb_tableKey.autoCache!{
                                // 缓存到内存
                                wb_tableKey.memory_cache.setObject(local_gif_image, forKey: image as AnyObject)
                            }
                        }else{
                            DispatchQueue.main.async(execute: {
                                [unowned self] in
                                self.wbImageView.image=UIImage(named: image)
                            })
                        }
                        return
                    }
                    // 图片是从网上获取的
                    let networkImage=self.getImageWithData(imageData as Data)
                    if wb_tableKey.autoCache!{
                        // 缓存到内存中
                        wb_tableKey.memory_cache.setObject(networkImage, forKey: image as AnyObject)
                        // 缓存到沙盒中
                        imageData.write(toFile: path, atomically: true)
                    }
                    DispatchQueue.main.async(execute: {
                        [unowned self] in
                        self.wbImageView.image=networkImage
                    })
                })
                return
            }
            let disk_cache_image=getImageWithData(data as Data)
            wbImageView.image=disk_cache_image
            if wb_tableKey.autoCache!{
                // 缓存到内存中
                wb_tableKey.memory_cache.setObject(disk_cache_image, forKey: image as AnyObject)
            }
            return
        }
        wbImageView.image=memory_cache_image as? UIImage
    }
    
    /// 下载图片，如果是gif，则计算动画时长
    private func getImageWithData(_ data:Data) -> UIImage{
        
        let imageSource=CGImageSourceCreateWithData(data as CFData, nil)
        let count=CGImageSourceGetCount(imageSource!)
        if count<=1{
            // 非gif
            return UIImage(data: data)!
        }else{
            // gif图片
            var images:[UIImage]=[]
            var duration:TimeInterval=0
            for index in 0..<count{
                let image=CGImageSourceCreateImageAtIndex(imageSource!, index, nil)
                if image==nil { continue }
                duration += Double(durationWithSource(imageSource!, atIndex: index))
                images.append(UIImage(cgImage: image!))
            }
            if duration != 0{
                duration = 0.1*Double(count)
            }
            return UIImage.animatedImage(with: images, duration: duration)!
        }
    }
    
    /// 获取每一帧的图片时长
    private func durationWithSource(_ source:CGImageSource, atIndex index:Int) -> CGFloat{
        var duration:CGFloat=0.1
        let propertiesRef=CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let properties=propertiesRef as! NSDictionary
        let gifProperties=properties.object(forKey: kCGImagePropertyGIFDictionary) as! NSDictionary
        
        var delayTime=gifProperties.object(forKey: kCGImagePropertyGIFUnclampedDelayTime) as! NSNumber!
        if delayTime != nil{
            duration=CGFloat(delayTime!.floatValue)
        }else{
            delayTime=gifProperties.object(forKey: kCGImagePropertyGIFDelayTime) as! NSNumber?
            if delayTime != nil{
                duration=CGFloat(delayTime!.floatValue)
            }
        }
        return duration
    }
    
    private func gifImageWithName(_ gifName:String) -> UIImage{
        
        let imagePath=Bundle.main.path(forResource: gifName, ofType: nil)
        let data=NSData(contentsOfFile: imagePath!)
        if data != nil{
            return getImageWithData(data as! Data)
        }
        return UIImage(named: gifName)!
    }
}
