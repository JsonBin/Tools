//
//  WBNavigationController.swift
//  WBExtension
//
//  Created by zwb on 17/2/23.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//


#if os(iOS) || os(watchOS) || os(tvOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

/// BarButton Style
///
/// - plain: 扁平化
/// - bordered: bordered
/// - done: done
public enum WBBarButtomItemStyle {
    case plain
    case bordered
    case done
}

// MARK: - 自定义BarButton

/// 自定义BarButtonItem
public class WBBarButtomItem: UIBarItem {
    
    /// Item View
    public var view:UIView?
    
    /// closure回调
    public typealias actionClosure = () -> Void
    
    /// tintColor. Default nil.
    public var tintColor:UIColor?
        {
        didSet{
            customButton?.setTitleColor(tintColor, for: .normal)
            customButton?.imageView?.tintColor = tintColor
        }
    }
    
    /// 字体大小
    public var font: UIFont? {
        didSet {
            customButton?.titleLabel?.font = font
        }
    }
    
    private var customButton: UIButton?
    private var closure: actionClosure?
    
    // MARK: - 系统式初始化
    
    /// init 系统式初始化 (文字)
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - style: WBBarButtomItemStyle
    ///   - target: target
    ///   - action: selector
    public convenience init(title: String?, style:WBBarButtomItemStyle = .plain, target:Any?, action:Selector?) {
        
        self.init()
        
        customButton = UIButton(type: .system)
        customButton?.setTitle(title, for: .normal)
        customButton?.titleLabel?.font = .systemFont(ofSize: 15)
        customButton?.setTitleColor(.black, for: .normal)
        customButton?.sizeToFit()
        customButton?.ve.height = 44
        customButton?.ve.width = 44
        customButton?.ve.center_y = 20 + 22
        customButton?.ve.x = 0
        
        view = customButton
        
        guard let customAction = action else {
            return
        }
        customButton?.addTarget(target, action: customAction, for: .touchUpInside)
        customButton?.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        customButton?.addTarget(self, action: #selector(buttonTouchUp(_:)), for: .touchUpOutside)
    }
    
    /// init 系统式初始化 (图片)
    ///
    /// - Parameters:
    ///   - image: 图片
    ///   - style: WBBarButtomItemStyle
    ///   - target: target
    ///   - action: selector
    public convenience init(image: UIImage?, style:WBBarButtomItemStyle = .plain, target:Any?, action:Selector?) {
        
        self.init()
        
        customButton = UIButton(type: .custom)
        customButton?.setImage(image, for: .normal)
        customButton?.setImage(image, for: .highlighted)
        customButton?.sizeToFit()
        customButton?.ve.height = 44
        customButton?.ve.width = 44
        customButton?.ve.center_y = 20 + 22
        customButton?.ve.x = 0
        
        view = customButton
        
        guard let customAction = action else {
            return
        }
        customButton?.addTarget(target, action: customAction, for: .touchUpInside)
        customButton?.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        customButton?.addTarget(self, action: #selector(buttonTouchUp(_:)), for: .touchUpOutside)
    }
    
    // MARK: - closure 初始化
    
    /// init closure式初始化 (文字)
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - style: WBBarButtomItemStyle
    ///   - action: closure
    public convenience init(title: String?, style:WBBarButtomItemStyle = .plain, action:actionClosure?) {
        
        self.init()
        
        customButton = UIButton(type: .system)
        customButton?.setTitle(title, for: .normal)
        customButton?.titleLabel?.font = .systemFont(ofSize: 15)
        customButton?.setTitleColor(.black, for: .normal)
        customButton?.sizeToFit()
        customButton?.ve.height = 44
        customButton?.ve.width = 44
        customButton?.ve.center_y = 20 + 22
        customButton?.ve.x = 0
        
        view = customButton
        
        closure = action
        
        customButton?.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
        customButton?.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        customButton?.addTarget(self, action: #selector(buttonTouchUp(_:)), for: .touchUpOutside)
    }
    
    /// init closure式初始化 (图片)
    ///
    /// - Parameters:
    ///   - image: 图片
    ///   - style: WBBarButtomItemStyle
    ///   - action: closure
    public convenience init(image: UIImage?, style:WBBarButtomItemStyle = .plain, action:actionClosure?) {
        
        self.init()
        
        customButton = UIButton(type: .custom)
        customButton?.setImage(image, for: .normal)
        customButton?.setImage(image, for: .highlighted)
        customButton?.sizeToFit()
        customButton?.ve.height = 44
        customButton?.ve.width = 44
        customButton?.ve.center_y = 20 + 22
        customButton?.ve.x = 0
        
        view = customButton
        
        closure = action
        
        customButton?.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
        customButton?.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        customButton?.addTarget(self, action: #selector(buttonTouchUp(_:)), for: .touchUpOutside)
    }
    
    
    // Button Action
    
    @objc private func buttonTouchUpInside(_ sender:UIButton) {
        
        if let block = closure {
            block()
        }
        UIView.animate(withDuration: 0.2) {
            sender.alpha = 1.0
        }
    }
    
    @objc private func buttonTouchDown(_ sender:UIButton) {
        
        sender.alpha = 0.3
    }
    
    @objc private func buttonTouchUp(_ sender:UIButton) {
        
        UIView.animate(withDuration: 0.3) {
            
            sender.alpha = 1.0
        }
    }
    
}


// MARK: - 自定义NavigationBar

/// 自定义NavigationBar
public class WBNavigationBar: UIView {
    
    public var showView: UIView?
    /// init
    ///
    /// - Parameter frame: frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initInterFace()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initInterFace()
    }
    
    /// init
    private func initInterFace() {
        
        frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 64)
        
        backgroundColor = UIColor(white: 1.0, alpha: 0.980)
        
        showView = UIView(frame: CGRect(x: 0, y: 63, width: UIScreen.main.bounds.width, height: 1))
        showView?.backgroundColor = UIColor(white: 0.869, alpha: 1.0)
        addSubview(showView!)
    }
    
}

// MARK: - 自定义NavigationItem

/// 自定义NavigationItem
public class WBNavigationItem {
    
    /// leftBarItem
    public var leftBarButtonItem:WBBarButtomItem?
        {
        didSet{
            setLeftBarButtonItem(leftBarButtonItem!)
        }
    }
    
    /// rightBarItem
    public var rightBarButtonItem:WBBarButtomItem?
        {
        didSet{
            setRightBarButtonItem(rightBarButtonItem!)
        }
    }
    
    /// 标题
    public var title:String?
        {
        didSet{
            setTitle(title)
        }
    }
    
    /// 标题控件
    public var titleLabel:UILabel?
    
    /// 需要设置的控制器
    public var _wb_viewController: UIViewController?
    
    
    /// private 设置标题
    ///
    /// - Parameter title: 标题
    private func setTitle(_ title:String?) {
        
        guard let newTitle = title else {
            titleLabel?.text = ""
            return
        }
        
        if newTitle == titleLabel?.text {
            return
        }
        
        if let _ = titleLabel {} else{
            titleLabel = UILabel()
            titleLabel?.font = .systemFont(ofSize: 17)
            titleLabel?.textColor = .black
            titleLabel?.textAlignment = .center
            titleLabel?.lineBreakMode = .byTruncatingTail
            
            _wb_viewController?.wb_navigationBar?.addSubview(titleLabel!)
        }
        
        titleLabel?.text = newTitle
        titleLabel?.sizeToFit()
        var otherButtonWidth:CGFloat = 0.0
        if let leftView = leftBarButtonItem?.view {
            otherButtonWidth += leftView.ve.width
        }
        if let rightView = rightBarButtonItem?.view {
            otherButtonWidth += rightView.ve.width
        }
        titleLabel?.ve.width = UIScreen.main.bounds.width - otherButtonWidth - 20
        titleLabel?.ve.center_y = 42
        titleLabel?.ve.center_x = UIScreen.main.bounds.width / 2
    }
    
    /// private 设置leftBarItem
    ///
    /// - Parameter item: WBBarButtomItem
    private func setLeftBarButtonItem(_ item:WBBarButtomItem) {
        guard let view = item.view else { fatalError("\(item) view not be nil!") }
        if let vc = _wb_viewController {
            
            leftBarButtonItem?.view?.removeFromSuperview()
            view.ve.center_y = 42
            vc.wb_navigationBar?.addSubview(view)
            
            let width = view.ve.width + view.ve.x
            titleLabel?.ve.x = width + 10
            titleLabel?.ve.width = UIScreen.main.bounds.width -  2 * (width + 10)
        }
    }
    
    /// private 设置rightBarItem
    ///
    /// - Parameter item: WBBarButtomItem
    private func setRightBarButtonItem(_ item:WBBarButtomItem) {
        guard let view = item.view else { fatalError("\(item) view not be nil!") }
        if let vc = _wb_viewController {
            
            rightBarButtonItem?.view?.removeFromSuperview()
            view.ve.x = UIScreen.main.bounds.width - view.ve.width
            view.ve.center_y = 42
            vc.wb_navigationBar?.addSubview(view)
            
            titleLabel?.ve.x = view.ve.width + 10
            titleLabel?.ve.width = UIScreen.main.bounds.width - 2 * (view.ve.width + 10)
        }
    }
    
}


// MARK: - Extension NavigationItem
extension UIViewController {
    
    /// 私有成员变量key
    private struct NavigationKey {
        public static let kNaviHidden = UnsafeRawPointer(bitPattern: "wbKNaviHidden".hashValue)
        public static let kNaviBarItem = UnsafeRawPointer(bitPattern: "wbKNaviBar".hashValue)
        public static let kNaviBarView = UnsafeRawPointer(bitPattern: "wbKNaviBarView".hashValue)
        public static let kEnableInnerInactive = UnsafeRawPointer(bitPattern: "wbKEnableInnerInactive".hashValue)
        public static let kInteractivePopGestureRecognizer = UnsafeRawPointer(bitPattern: "wbkInteractivePopGestureRecognizer".hashValue)
        public static let kPopViewControllerClosure = UnsafeRawPointer(bitPattern: "wbkPopViewControllerClosure".hashValue)
    }
    
    /// 是否支持添加右滑返回上一级, 默认为true
    public var isEnableInnerInactiveGesture: Bool! {
        set{
            objc_setAssociatedObject(self, NavigationKey.kEnableInnerInactive, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get{
            guard let canEnable = objc_getAssociatedObject(self, NavigationKey.kEnableInnerInactive) as? Bool else {
                return true
            }
            return canEnable
        }
    }
    
    /// 右滑返回上一级的时候响应的回调
    public var popViewControllerClosure: (() -> Void )? {
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, NavigationKey.kPopViewControllerClosure, value, .OBJC_ASSOCIATION_COPY)
            }
        }
        get{
            guard let closure = objc_getAssociatedObject(self, NavigationKey.kPopViewControllerClosure) else {
                return nil
            }
            return closure as? () -> Void
        }
    }
    
    /// 是否响应系统返回手势, 默认true
    public var isInteractivePopGestureRecognizer: Bool! {
        set{
            objc_setAssociatedObject(self, NavigationKey.kInteractivePopGestureRecognizer, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get{
            guard let canEnable = objc_getAssociatedObject(self, NavigationKey.kInteractivePopGestureRecognizer) as? Bool else {
                return true
            }
            return canEnable
        }
    }
    
    /// NavigationItem
    var wb_navigationItem:WBNavigationItem? {
        set{
            if let value = newValue {
                objc_setAssociatedObject(self, NavigationKey.kNaviBarItem, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get{
            guard let item = objc_getAssociatedObject(self, NavigationKey.kNaviBarItem) as? WBNavigationItem else {
                /*fatalError("Not Found NavigationItem. \(#file).[\(#function)]:\(#line)")*/
                return nil
            }
            return item
        }
    }
    
    /// NavigationBar
    var wb_navigationBar:WBNavigationBar? {
        set{
            if let value = newValue {
                objc_setAssociatedObject(self, NavigationKey.kNaviBarView, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }else{
                objc_setAssociatedObject(self, NavigationKey.kNaviBarView, WBNavigationBar(), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get{
            guard let bar = objc_getAssociatedObject(self, NavigationKey.kNaviBarView) as? WBNavigationBar else {
                /*fatalError("Not Found NavigationBar. \(#file).[\(#function)]:\(#line)")*/
                return nil
            }
            return bar
        }
    }
    
    /// 设置NavigationBar隐藏/显示
    var wb_navigationBarHidden: Bool {
        set{
            objc_setAssociatedObject(self, NavigationKey.kNaviHidden, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get{
            guard let hidden = objc_getAssociatedObject(self, NavigationKey.kNaviHidden) as? Bool else {
                return false
            }
            return hidden
        }
    }
    
    /// 设置NavigationBar隐藏/显示
    ///
    /// - Parameters:
    ///   - hidden: 隐藏/显示
    ///   - animation: 是否添加动画
    public func wb_setNavigationBarHidden(_ hidden: Bool, animation:Bool) {
        
        if hidden {
            if animation {
                
                UIView.animate(withDuration: 0.3, animations: {
                    if let bar = self.wb_navigationBar {
                        bar.ve.y = -44
                        for view in bar.subviews {
                            view.alpha = 0.0
                        }
                    }
                }, completion: { (finished) in
                    
                    self.wb_navigationBarHidden = true
                })
            }
            else{
                if let bar = wb_navigationBar {
                    for view in bar.subviews{
                        view.alpha = 0.0
                    }
                }
                
                wb_navigationBarHidden = true
            }
        }else{
            if animation{
                
                UIView.animate(withDuration: 0.3, animations: {
                    if let bar = self.wb_navigationBar {
                        bar.ve.y = 0
                        for view in bar.subviews{
                            view.alpha = 1.0
                        }
                    }
                    
                }, completion: { (finished) in
                    
                    self.wb_navigationBarHidden = false
                })
            }
            else{
                if let bar = wb_navigationBar {
                    for view in bar.subviews{
                        view.alpha = 1.0
                    }
                }
                
                wb_navigationBarHidden = false
            }
        }
    }
}

// MARK: -

/// 使用初始化方法，添加右滑手势返回上一级
public class WBNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    /// private property
    private var panRecognizer:UIPanGestureRecognizer?
    private var interactivePopTransition:UIPercentDrivenInteractiveTransition?
    private var lastViewController:UIViewController?
    private var isTransiting:Bool = false
    private var popClosure: (() -> Void)?
    
    /// loadView
    public override func loadView() {
        super.loadView()
    }
    
    /// viewDidLoad
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        isTransiting = false
        
        isNavigationBarHidden = true
        
        interactivePopGestureRecognizer?.delegate = self
        super.delegate = self
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanRecognizer(_:)))
        
    }
    
    
    // MARK: - Push & Pop
    
    /// Push 推送
    ///
    /// - Parameters:
    ///   - viewController: 需要推送的vc
    ///   - animated: 是否有动画效果
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        super.pushViewController(viewController, animated: animated)
        
        if !isTransiting {
            
            interactivePopGestureRecognizer?.isEnabled = false
        }
        
        configureNavigationBarForViewController(viewController)
    }
    
    
    /// Pop 返回
    ///
    /// - Parameter animated: 是否加载动画
    /// - Returns: 返回的vc
    @discardableResult public override func popViewController(animated: Bool) -> UIViewController? {
        
        if isTransiting {
            
            isTransiting = false
            return nil
        }
        return super.popViewController(animated: animated)
    }
    
    // MARK: - UINavigationControllerDelegate
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        isTransiting = true
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        isTransiting = false
        
        popClosure = viewController.popViewControllerClosure
        
        if let bar = viewController.wb_navigationBar {
            viewController.view.bringSubview(toFront: bar)
        }
        
        if responds(to: #selector(getter: interactivePopGestureRecognizer)) {
            if navigationController.viewControllers.count == 1{
                interactivePopGestureRecognizer?.delegate = nil
                delegate = nil
                interactivePopGestureRecognizer?.isEnabled = false
            }else{
                if viewController.isInteractivePopGestureRecognizer {
                    interactivePopGestureRecognizer?.isEnabled = true
                }else{
                    interactivePopGestureRecognizer?.isEnabled = false
                }
            }
        }
        
        if viewController.isEnableInnerInactiveGesture {
            
            var hasPanGestrue:Bool = false
            if let gestures = viewController.view.gestureRecognizers {
                
                for recognizer in gestures {
                    if recognizer is UIPanGestureRecognizer {
                        if recognizer is UIScreenEdgePanGestureRecognizer {
                            
                        }else{
                            hasPanGestrue = true
                        }
                    }
                }
            }
            
            if !hasPanGestrue && navigationController.viewControllers.count > 1{
                
                if let pan = panRecognizer {
                    viewController.view.addGestureRecognizer(pan)
                }
            }
        }
        viewController.navigationController?.delegate = self
    }
    
    // MARK: - Animation
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .pop && navigationController.viewControllers.count >= 1 && fromVC.isEnableInnerInactiveGesture {
            return WBNavigationPopAnimation()
        }else if operation == .push {
            return WBNavigationPushAnimation()
        }
        return nil
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        if animationController is WBNavigationPopAnimation && navigationController.isEnableInnerInactiveGesture {
             return interactivePopTransition
        }
        return nil
    }
    
    // MARK: - Private
    var startLocationX:CGFloat = 0.0
    /// 手势响应
    ///
    /// - Parameter recognizer: 手势
    @objc private func handlePanRecognizer(_ recognizer:UIGestureRecognizer) {
        
        let location = recognizer.location(in: view)
        
        let offset = location.x - startLocationX
        
        var progress = offset / UIScreen.main.bounds.width
        progress = min(1.0, max(0.0, progress))
        
        if recognizer.state == .began {
            startLocationX = location.x
            interactivePopTransition = UIPercentDrivenInteractiveTransition()
            popViewController(animated: true)
        }
        else if recognizer.state == .changed{
            
            interactivePopTransition?.update(progress)
        }else if recognizer.state == .ended || recognizer.state == .cancelled {
            
            if progress > 0.55{
                // 完成返回上一级
                interactivePopTransition?.completionSpeed = 0.4
                interactivePopTransition?.finish()
                if let closure = popClosure {
                    closure()
                }
            }else{
                // 失败停留本页
                interactivePopTransition?.completionSpeed = 0.5
                interactivePopTransition?.cancel()
                
                isTransiting = false
            }
            
            interactivePopTransition = nil
        }
    }
    
    /// 动态设置vc的属性
    ///
    /// - Parameter viewController: vc
    dynamic private func configureNavigationBarForViewController(_ viewController:UIViewController) {
        
        if viewController.wb_navigationItem == nil {
            
            let navigationItem = WBNavigationItem()
            navigationItem._wb_viewController = viewController
            /*navigationItem.setValue(viewController, forKey: "_wb_viewController")*/
            viewController.wb_navigationItem = navigationItem
        }
        
        if viewController.wb_navigationBar == nil {
            viewController.wb_navigationBar = WBNavigationBar()
            viewController.view.addSubview(viewController.wb_navigationBar!)
        }
    }
}

// MARK: -

/// 自定义Pop动画效果
public class WBNavigationPopAnimation: NSObject , UIViewControllerAnimatedTransitioning{
    
    private let screen_width = UIScreen.main.bounds.width
    private let kToBackgroundInitAlpha:CGFloat = 0.15
    private var toBackgroundView:UIView?
    private var shadowImageView:UIImageView?
    
    override init() {
        
        let screen_height = UIScreen.main.bounds.height
        
        toBackgroundView = UIView()
        
        shadowImageView = UIImageView(frame: CGRect(x: -1, y: 0, width: 1, height: screen_height))
        shadowImageView?.backgroundColor = UIColor(white: 0.0, alpha: 0.25)
        shadowImageView?.contentMode = .scaleAspectFill
        
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        guard let toBackgroundView = toBackgroundView else { return }
        guard let shadowImageView = shadowImageView else { return }
        
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        containerView.addSubview(fromViewController.view)
        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        containerView.insertSubview(toBackgroundView, belowSubview: fromViewController.view)
        containerView.insertSubview(shadowImageView, belowSubview: fromViewController.view)
        toViewController.view.frame = CGRect(x: -90, y: 0, width: screen_width, height: toViewController.view.ve.height)
        toBackgroundView.frame = CGRect(x: -90, y: 0, width: screen_width, height: toViewController.view.ve.height)
        shadowImageView.ve.x = -1
        shadowImageView.alpha = 1.3
        
        toBackgroundView.backgroundColor = .black
        toBackgroundView.alpha = kToBackgroundInitAlpha
        
        // Configure Navi Transition
        
        var naviBarView:UIView?
        
        var toNaviLeft:UIView?
        var toNaviRight:UIView?
        var toNaviTitle:UIView?
        
        var fromNaviLeft:UIView?
        var fromNaviRight:UIView?
        var fromNaviTitle:UIView?
        var lineView: UIView?
        
        if fromViewController.wb_navigationBarHidden || toViewController.wb_navigationBarHidden {}
        else{
            
            naviBarView = UIView(frame: CGRect(x: 0, y: 0, width: screen_width, height: 64))
            naviBarView?.backgroundColor = fromViewController.wb_navigationBar?.backgroundColor
            containerView.addSubview(naviBarView!)
            
            if let hidden = fromViewController.wb_navigationBar?.showView?.isHidden, !hidden {
                lineView = UIView(frame: CGRect(x: 0, y: 64, width: screen_width, height: 0.5))
                lineView?.backgroundColor = fromViewController.wb_navigationBar?.showView?.backgroundColor
                naviBarView?.addSubview(lineView!)
            }
            
            toNaviLeft = toViewController.wb_navigationItem?.leftBarButtonItem?.view
            toNaviRight = toViewController.wb_navigationItem?.rightBarButtonItem?.view
            toNaviTitle = toViewController.wb_navigationItem?.titleLabel
            
            fromNaviLeft = fromViewController.wb_navigationItem?.leftBarButtonItem?.view
            fromNaviRight = fromViewController.wb_navigationItem?.rightBarButtonItem?.view
            fromNaviTitle = fromViewController.wb_navigationItem?.titleLabel
            
            // add to containerView
            
            if let toTitle = toNaviTitle {
                containerView.addSubview(toTitle)
                toTitle.alpha = 0.0
                toTitle.ve.center_x = 44
            }
            if let toLeft = toNaviLeft {
                containerView.addSubview(toLeft)
                toLeft.alpha = 0.0
            }
            if let toRight = toNaviRight {
                containerView.addSubview(toRight)
                toRight.alpha = 0.0
            }
            
            
            if let fromTitle = fromNaviTitle {
                containerView.addSubview(fromTitle)
                fromTitle.alpha = 1.0
            }
            if let fromLeft = fromNaviLeft {
                containerView.addSubview(fromLeft)
                fromLeft.alpha = 1.0
                fromLeft.ve.x = fromLeft.ve.x
            }
            if let fromRight = fromNaviRight {
                containerView.addSubview(fromRight)
                fromRight.alpha = 1.0
                fromRight.ve.x = screen_width - fromRight.ve.width
            }
            
        }
        
        // End configure
        
        UIView.animate(withDuration: duration, animations: {
            
            naviBarView?.backgroundColor = toViewController.wb_navigationBar?.backgroundColor
            lineView?.backgroundColor = toViewController.wb_navigationBar?.showView?.backgroundColor
            
            toViewController.view.ve.x = 0
            self.toBackgroundView?.ve.x = 0
            fromViewController.view.ve.x = self.screen_width
            
            self.shadowImageView?.alpha = 0.2
            self.shadowImageView?.ve.x = self.screen_width - 1
            
            self.toBackgroundView?.alpha = 0.0
            
            if let fromTitle = fromNaviTitle {
                fromTitle.alpha = 0.0
                fromTitle.ve.center_x = self.screen_width + 10
            }
            if let fromLeft = fromNaviLeft { fromLeft.alpha = 0.0 }
            if let fromRight = fromNaviRight { fromRight.alpha = 0.0 }
            
            
            if let toTitle = toNaviTitle {
                toTitle.alpha = 1.0
                toTitle.ve.center_x = self.screen_width / 2
            }
            if let toLeft = toNaviLeft {  toLeft.alpha = 1.0  }
            if let toRight = toNaviRight {  toRight.alpha = 1.0  }
            
        }) { (finished) in
            
            if transitionContext.transitionWasCancelled {
                if let toTitle = toNaviTitle {
                    toTitle.alpha = 1.0
                    toTitle.ve.center_x = self.screen_width / 2
                }
                if let toLeft = toNaviLeft {
                    toLeft.alpha = 1.0
                }
                if let toRight = toNaviRight {
                    toRight.alpha = 1.0
                }
                self.toBackgroundView?.alpha = self.kToBackgroundInitAlpha
            }
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            naviBarView?.removeFromSuperview()
            self.toBackgroundView?.removeFromSuperview()
            
            if let toTitle = toNaviTitle {
                toTitle.removeFromSuperview()
                toViewController.wb_navigationBar?.addSubview(toTitle)
            }
            if let toLeft = toNaviLeft {
                toLeft.removeFromSuperview()
                toViewController.wb_navigationBar?.addSubview(toLeft)
            }
            if let toRight = toNaviRight {
                toRight.removeFromSuperview()
                toViewController.wb_navigationBar?.addSubview(toRight)
            }
            
            if let fromTitle = fromNaviTitle {
                fromTitle.removeFromSuperview()
                fromViewController.wb_navigationBar?.addSubview(fromTitle)
            }
            if let fromLeft = fromNaviLeft {
                fromLeft.removeFromSuperview()
                fromViewController.wb_navigationBar?.addSubview(fromLeft)
            }
            if let fromRight = fromNaviRight {
                fromRight.removeFromSuperview()
                fromViewController.wb_navigationBar?.addSubview(fromRight)
            }
            
        }
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.3
    }
    
}


// MARK: -

/// 自定义Push 动画效果
public class WBNavigationPushAnimation: NSObject , UIViewControllerAnimatedTransitioning {
    
    private let screen_width = UIScreen.main.bounds.width
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        containerView.addSubview(fromViewController.view)
        containerView.addSubview(toViewController.view)
        
        fromViewController.view.frame = CGRect(x: 0, y: 0, width: screen_width, height: fromViewController.view.frame.size.height)
        toViewController.view.frame = CGRect(x: screen_width, y: 0, width: screen_width, height: toViewController.view.frame.size.height)
        
        // Configure Navi Transition
        
        var naviBarView:UIView?
        
        var toNaviLeft:UIView?
        var toNaviRight:UIView?
        var toNaviTitle:UIView?
        
        var fromNaviLeft:UIView?
        var fromNaviRight:UIView?
        var fromNaviTitle:UIView?
        
        var lineView: UIView?
        
        if fromViewController.wb_navigationBarHidden || toViewController.wb_navigationBarHidden{}
        else{
            
            naviBarView = UIView(frame: CGRect(x: 0, y: 0, width: screen_width, height: 64))
            naviBarView?.backgroundColor = fromViewController.wb_navigationBar?.backgroundColor
            containerView.addSubview(naviBarView!)
            
            if let hidden = fromViewController.wb_navigationBar?.showView?.isHidden, !hidden {
                lineView = UIView(frame: CGRect(x: 0, y: 64, width: screen_width, height: 0.5))
                lineView?.backgroundColor = fromViewController.wb_navigationBar?.showView?.backgroundColor
                naviBarView?.addSubview(lineView!)
            }
            
            toNaviLeft = toViewController.wb_navigationItem?.leftBarButtonItem?.view
            toNaviRight = toViewController.wb_navigationItem?.rightBarButtonItem?.view
            toNaviTitle = toViewController.wb_navigationItem?.titleLabel
            
            fromNaviLeft = fromViewController.wb_navigationItem?.leftBarButtonItem?.view
            fromNaviRight = fromViewController.wb_navigationItem?.rightBarButtonItem?.view
            fromNaviTitle = fromViewController.wb_navigationItem?.titleLabel
            
            
            // add to containerView
            
            if let toTitle = toNaviTitle {
                containerView.addSubview(toTitle)
                toTitle.alpha = 0.0
                toTitle.ve.center_y = 44
                toTitle.ve.center_x = screen_width
            }
            if let toLeft = toNaviLeft {
                containerView.addSubview(toLeft)
                toLeft.alpha = 0.0
            }
            if let toRight = toNaviRight {
                containerView.addSubview(toRight)
                toRight.alpha = 0.0
                toRight.ve.x = screen_width + 70 - toRight.ve.width
            }
            
            
            if let fromTitle = fromNaviTitle {
                containerView.addSubview(fromTitle)
                fromTitle.alpha = 1.0
            }
            if let fromLeft = fromNaviLeft {
                containerView.addSubview(fromLeft)
                fromLeft.alpha = 1.0
            }
            if let fromRight = fromNaviRight {
                containerView.addSubview(fromRight)
                fromRight.alpha = 1.0
            }
            
        }
        
        // End configure
        
        UIView.animate(withDuration: duration, animations: {
            naviBarView?.backgroundColor = toViewController.wb_navigationBar?.backgroundColor
            lineView?.backgroundColor = toViewController.wb_navigationBar?.showView?.backgroundColor
            
            toViewController.view.ve.x = 0
            fromViewController.view.ve.x = -120
            
            if let fromTitle = fromNaviTitle {
                fromTitle.alpha = 0.0
                fromTitle.ve.center_x = 0
            }
            if let fromLeft = fromNaviLeft { fromLeft.alpha = 0.0 }
            if let fromRight = fromNaviRight { fromRight.alpha = 0.0 }
            
            
            if let toTitle = toNaviTitle {
                toTitle.alpha = 1.0
                toTitle.ve.center_x = self.screen_width / 2
            }
            if let toLeft = toNaviLeft {
                toLeft.alpha = 1.0
            }
            if let toRight = toNaviRight {
                toRight.alpha = 1.0
                toRight.ve.x = self.screen_width - toRight.ve.width
            }
            
        }) { (finished) in
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            naviBarView?.removeFromSuperview()
            
            if let fromTitle = fromNaviTitle {
                fromTitle.alpha = 1.0
                fromTitle.ve.center_x = self.screen_width / 2
                fromTitle.removeFromSuperview()
                fromViewController.wb_navigationBar?.addSubview(fromTitle)
            }
            if let fromLeft = fromNaviLeft {
                fromLeft.alpha = 1.0
                fromLeft.ve.x = fromLeft.ve.x
                fromLeft.removeFromSuperview()
                fromViewController.wb_navigationBar?.addSubview(fromLeft)
            }
            if let fromRight = fromNaviRight {
                fromRight.alpha = 1.0
                fromRight.ve.x = self.screen_width - fromRight.ve.width
                fromRight.removeFromSuperview()
                fromViewController.wb_navigationBar?.addSubview(fromRight)
            }
            
            
            if let toTitle = toNaviTitle {
                toTitle.removeFromSuperview()
                toViewController.wb_navigationBar?.addSubview(toTitle)
            }
            if let toLeft = toNaviLeft {
                toLeft.removeFromSuperview()
                toViewController.wb_navigationBar?.addSubview(toLeft)
            }
            if let toRight = toNaviRight {
                toRight.removeFromSuperview()
                toViewController.wb_navigationBar?.addSubview(toRight)
            }
            
        }
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.3
    }
}
