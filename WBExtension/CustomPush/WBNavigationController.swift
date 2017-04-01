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
            customButton.setTitleColor(tintColor, for: .normal)
            customButton.imageView?.tintColor = tintColor
        }
    }
    
    private var customButton:UIButton!
    private var closure:actionClosure!
    
    // MARK: - 系统式初始化
    
    /// init 系统式初始化 (文字)
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - style: WBBarButtomItemStyle
    ///   - target: target
    ///   - action: selector
    public convenience init(title: String, style:WBBarButtomItemStyle, target:Any?, action:Selector?) {
        
        self.init()
        
        customButton = UIButton(type: .system)
        customButton.setTitle(title, for: .normal)
        customButton.titleLabel!.font = UIFont.systemFont(ofSize: 15)
        customButton.setTitleColor(.black, for: .normal)
        customButton.sizeToFit()
        customButton.ve.height = 44
        customButton.ve.width += 30
        customButton.ve.center_y = 20 + 22
        customButton.ve.x = 0
        
        view = customButton
        
        guard let customAction=action else {
            return
        }
        customButton.addTarget(target, action: customAction, for: .touchUpInside)
        customButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        customButton.addTarget(self, action: #selector(buttonTouchUp(_:)), for: .touchDragOutside)
    }
    
    /// init 系统式初始化 (图片)
    ///
    /// - Parameters:
    ///   - image: 图片
    ///   - style: WBBarButtomItemStyle
    ///   - target: target
    ///   - action: selector
    public convenience init(image: UIImage, style:WBBarButtomItemStyle, target:Any?, action:Selector?) {
        
        self.init()
        
        customButton = UIButton(type: .custom)
        customButton.setImage(image, for: .normal)
        customButton.setImage(image, for: .highlighted)
        customButton.sizeToFit()
        customButton.ve.height = 44
        customButton.ve.width += 30
        customButton.ve.center_y = 20 + 22
        customButton.ve.x = 0
        
        view = customButton
        
        guard let customAction=action else {
            return
        }
        customButton.addTarget(target, action: customAction, for: .touchUpInside)
        customButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        customButton.addTarget(self, action: #selector(buttonTouchUp(_:)), for: .touchDragOutside)
    }
    
    // MARK: - closure 初始化
    
    /// init closure式初始化 (文字)
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - style: WBBarButtomItemStyle
    ///   - action: closure
    public convenience init(title: String, style:WBBarButtomItemStyle, action:actionClosure?) {
        
        self.init()
        
        customButton = UIButton(type: .system)
        customButton.setTitle(title, for: .normal)
        customButton.titleLabel!.font = UIFont.systemFont(ofSize: 15)
        customButton.setTitleColor(.black, for: .normal)
        customButton.sizeToFit()
        customButton.ve.height = 44
        customButton.ve.width += 30
        customButton.ve.center_y = 20 + 22
        customButton.ve.x = 0
        
        view = customButton
        
        closure = action
        
        customButton.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
        customButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        customButton.addTarget(self, action: #selector(buttonTouchUp(_:)), for: .touchDragOutside)
    }
    
    /// init closure式初始化 (图片)
    ///
    /// - Parameters:
    ///   - image: 图片
    ///   - style: WBBarButtomItemStyle
    ///   - action: closure
    public convenience init(image: UIImage, style:WBBarButtomItemStyle, action:actionClosure?) {
        
        self.init()
        
        customButton = UIButton(type: .custom)
        customButton.setImage(image, for: .normal)
        customButton.setImage(image, for: .highlighted)
        customButton.sizeToFit()
        customButton.ve.height = 44
        customButton.ve.width += 30
        customButton.ve.center_y = 20 + 22
        customButton.ve.x = 0
        
        view = customButton
        
        closure = action
        
        customButton.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
        customButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        customButton.addTarget(self, action: #selector(buttonTouchUp(_:)), for: .touchDragOutside)
    }
    
    
    // Button Action
    
    @objc private func buttonTouchUpInside(_ sender:UIButton) {
        
        if closure != nil{
            closure()
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
        
        let lineView = UIView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: 0.5))
        lineView.backgroundColor = UIColor(white: 0.869, alpha: 1.0)
        addSubview(lineView)
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
    public var _wb_viewController:UIViewController?
    
    
    /// private 设置标题
    ///
    /// - Parameter title: 标题
    private func setTitle(_ title:String?) {
        
        guard let newTitle=title else {
            titleLabel?.text=""
            return
        }
        
        if newTitle==titleLabel?.text{
            return
        }
        
        if titleLabel==nil{
            titleLabel=UILabel()
            titleLabel?.font = UIFont.systemFont(ofSize: 17)
            titleLabel?.textColor = .black
            titleLabel?.textAlignment = .center
            titleLabel?.lineBreakMode = .byTruncatingTail
            
            _wb_viewController?.wb_navigationBar.addSubview(titleLabel!)
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
        
        if _wb_viewController != nil{
            
            leftBarButtonItem?.view?.removeFromSuperview()
            item.view?.ve.x = 0
            item.view?.ve.center_y = 42
            _wb_viewController?.wb_navigationBar.addSubview(item.view!)
            
            titleLabel?.ve.width -= item.view!.ve.width
            titleLabel?.ve.x = item.view!.ve.width + 10
        }
    }
    
    /// private 设置rightBarItem
    ///
    /// - Parameter item: WBBarButtomItem
    private func setRightBarButtonItem(_ item:WBBarButtomItem) {
        
        if _wb_viewController != nil{
            
            rightBarButtonItem?.view?.removeFromSuperview()
            item.view?.ve.x = UIScreen.main.bounds.width - item.view!.ve.width
            item.view?.ve.center_y = 42
            _wb_viewController?.wb_navigationBar.addSubview(item.view!)
            
            titleLabel?.ve.width -= item.view!.ve.width
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
    }
    
    /// NavigationItem
    var wb_navigationItem:WBNavigationItem! {
        set{
            objc_setAssociatedObject(self, NavigationKey.kNaviBarItem, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            guard let item=objc_getAssociatedObject(self, NavigationKey.kNaviBarItem) else {
                /*fatalError("Not Found NavigationItem. \(#file).[\(#function)]:\(#line)")*/
                return nil
            }
            return item as! WBNavigationItem
        }
    }
    
    /// NavigationBar
    var wb_navigationBar:WBNavigationBar! {
        set{
            objc_setAssociatedObject(self, NavigationKey.kNaviBarView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            guard let bar=objc_getAssociatedObject(self, NavigationKey.kNaviBarView) else {
                /*fatalError("Not Found NavigationBar. \(#file).[\(#function)]:\(#line)")*/
                return nil
            }
            return bar as! WBNavigationBar
        }
    }
    
    /// 设置NavigationBar隐藏/显示
    var wb_navigationBarHidden:Bool {
        set{
            objc_setAssociatedObject(self, NavigationKey.kNaviHidden, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get{
            guard let hidden=objc_getAssociatedObject(self, NavigationKey.kNaviHidden) else {
                return false
            }
            return hidden as! Bool
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
                    
                    self.wb_navigationBar.ve.y = -44
                    for view in self.wb_navigationBar.subviews{
                        view.alpha = 0.0
                    }
                }, completion: { (finished) in
                    
                    self.wb_navigationBarHidden = true
                })
            }
            else{
                
                for view in wb_navigationBar.subviews{
                    view.alpha = 0.0
                }
                wb_navigationBarHidden = true
            }
        }else{
            if animation{
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.wb_navigationBar.ve.y = 0
                    for view in self.wb_navigationBar.subviews{
                        view.alpha = 1.0
                    }
                }, completion: { (finished) in
                    
                    self.wb_navigationBarHidden = false
                })
            }
            else{
                
                for view in wb_navigationBar.subviews{
                    view.alpha = 1.0
                }
                wb_navigationBarHidden = false
            }
        }
    }
}

// MARK: -

/// 使用初始化方法，添加右滑手势返回上一级
public class WBNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    /// 是否支持添加右滑返回上一级
    public var isEnableInnerInactiveGesture:Bool = true
    
    /// private property
    private var panRecognizer:UIPanGestureRecognizer!
    private var interactivePopTransition:UIPercentDrivenInteractiveTransition!
    private var lastViewController:UIViewController!
    private var isTransiting:Bool! = false
    
    
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
        
        if !isTransiting!{
            
            interactivePopGestureRecognizer?.isEnabled = false
        }
        
        configureNavigationBarForViewController(viewController)
    }
    
    
    /// Pop 返回
    ///
    /// - Parameter animated: 是否加载动画
    /// - Returns: 返回的vc
    @discardableResult public override func popViewController(animated: Bool) -> UIViewController? {
        
        if isTransiting!{
            
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
        
        viewController.view.bringSubview(toFront: viewController.wb_navigationBar)
        
        if responds(to: #selector(getter: interactivePopGestureRecognizer)){
            if navigationController.viewControllers.count==1{
                interactivePopGestureRecognizer?.delegate = nil
                delegate = nil
                interactivePopGestureRecognizer?.isEnabled = false
            }else{
                
                interactivePopGestureRecognizer?.isEnabled = true
            }
        }
        
        if isEnableInnerInactiveGesture {
            
            var hasPanGestrue:Bool = false
            if let gestures  = viewController.view.gestureRecognizers {
                
                for recognizer in gestures {
                    if recognizer.isKind(of: UIPanGestureRecognizer.classForCoder()){
                        if recognizer.isKind(of: UIScreenEdgePanGestureRecognizer.classForCoder()){
                            
                        }
                        else{
                            hasPanGestrue = true
                        }
                    }
                }
            }
            
            if !hasPanGestrue && navigationController.viewControllers.count > 1{
                
                viewController.view.addGestureRecognizer(panRecognizer)
            }
        }
        viewController.navigationController?.delegate = self
    }
    
    // MARK: - Animation
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .pop && navigationController.viewControllers.count >= 1 && isEnableInnerInactiveGesture {
            return WBNavigationPopAnimation()
        }else if operation == .push {
            return WBNavigationPushAnimation()
        }
        return nil
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        if animationController.isKind(of: WBNavigationPopAnimation.classForCoder()) && isEnableInnerInactiveGesture {
            
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
            
            interactivePopTransition.update(progress)
        }else if recognizer.state == .ended || recognizer.state == .cancelled {
            
            if progress > 0.55{
                
                interactivePopTransition.completionSpeed = 0.4
                interactivePopTransition.finish()
            }else{
                interactivePopTransition.completionSpeed = 0.5
                interactivePopTransition.cancel()
                
                isTransiting = false
            }
            
            interactivePopTransition = nil
        }
    }
    
    /// 动态设置vc的属性
    ///
    /// - Parameter viewController: vc
    dynamic private func configureNavigationBarForViewController(_ viewController:UIViewController) {
        
        if viewController.wb_navigationItem == nil{
            
            let navigationItem = WBNavigationItem()
            navigationItem._wb_viewController = viewController
            /*navigationItem.setValue(viewController, forKey: "_wb_viewController")*/
            viewController.wb_navigationItem = navigationItem
        }
        
        if viewController.wb_navigationBar == nil {
            viewController.wb_navigationBar = WBNavigationBar()
            viewController.view.addSubview(viewController.wb_navigationBar)
        }
    }
}

// MARK: -

/// 自定义Pop动画效果
public class WBNavigationPopAnimation: NSObject , UIViewControllerAnimatedTransitioning{
    
    private let screen_width = UIScreen.main.bounds.width
    private let kToBackgroundInitAlpha:CGFloat = 0.15
    private var toBackgroundView:UIView!
    private var shadowImageView:UIImageView!
    
    override init() {
        
        let screen_height = UIScreen.main.bounds.height
        
        toBackgroundView = UIView()
        
        shadowImageView = UIImageView(frame: CGRect(x: -1, y: 0, width: 1, height: screen_height))
        shadowImageView.backgroundColor = UIColor(white: 0.0, alpha: 0.25)
        shadowImageView.contentMode = .scaleAspectFill
        
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
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
        
        var naviBarView:UIView!
        
        var toNaviLeft:UIView!
        var toNaviRight:UIView!
        var toNaviTitle:UIView!
        
        var fromNaviLeft:UIView!
        var fromNaviRight:UIView!
        var fromNaviTitle:UIView!
        
        if fromViewController.wb_navigationBarHidden || toViewController.wb_navigationBarHidden{}
        else{
            
            naviBarView = UIView(frame: CGRect(x: 0, y: 0, width: screen_width, height: 64))
            naviBarView.backgroundColor = UIColor(white: 1.0, alpha: 0.980)
            containerView.addSubview(naviBarView)
            
            let lineView=UIView(frame: CGRect(x: 0, y: 64, width: screen_width, height: 0.5))
            lineView.backgroundColor = UIColor(white: 0.869, alpha: 1.0)
            naviBarView.addSubview(lineView)
            
            toNaviLeft = toViewController.wb_navigationItem.leftBarButtonItem?.view
            toNaviRight = toViewController.wb_navigationItem.rightBarButtonItem?.view
            toNaviTitle = toViewController.wb_navigationItem.titleLabel
            
            fromNaviLeft = fromViewController.wb_navigationItem.leftBarButtonItem?.view
            fromNaviRight = fromViewController.wb_navigationItem.rightBarButtonItem?.view
            fromNaviTitle = fromViewController.wb_navigationItem.titleLabel
            
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
                fromLeft.ve.x = 0
            }
            if let fromRight = fromNaviRight {
                containerView.addSubview(fromRight)
                fromRight.alpha = 1.0
                fromRight.ve.x = screen_width - fromRight.ve.width
            }
            
        }
        
        // End configure
        
        UIView.animate(withDuration: duration, animations: {
            
            toViewController.view.ve.x = 0
            self.toBackgroundView.ve.x = 0
            fromViewController.view.ve.x = self.screen_width
            
            self.shadowImageView.alpha = 0.2
            self.shadowImageView.ve.x = self.screen_width - 1
            
            self.toBackgroundView.alpha = 0.0
            
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
            
            if transitionContext.transitionWasCancelled{
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
                self.toBackgroundView.alpha = self.kToBackgroundInitAlpha
            }
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            naviBarView.removeFromSuperview()
            self.toBackgroundView.removeFromSuperview()
            
            if let toTitle = toNaviTitle {
                toTitle.removeFromSuperview()
                toViewController.wb_navigationBar.addSubview(toTitle)
            }
            if let toLeft = toNaviLeft {
                toLeft.removeFromSuperview()
                toViewController.wb_navigationBar.addSubview(toLeft)
            }
            if let toRight = toNaviRight {
                toRight.removeFromSuperview()
                toViewController.wb_navigationBar.addSubview(toRight)
            }
            
            if let fromTitle = fromNaviTitle {
                fromTitle.removeFromSuperview()
                fromViewController.wb_navigationBar.addSubview(fromTitle)
            }
            if let fromLeft = fromNaviLeft {
                fromLeft.removeFromSuperview()
                fromViewController.wb_navigationBar.addSubview(fromLeft)
            }
            if let fromRight = fromNaviRight {
                fromRight.removeFromSuperview()
                fromViewController.wb_navigationBar.addSubview(fromRight)
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
        
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        containerView.addSubview(fromViewController.view)
        containerView.addSubview(toViewController.view)
        
        fromViewController.view.frame = CGRect(x: 0, y: 0, width: screen_width, height: fromViewController.view.frame.size.height)
        toViewController.view.frame = CGRect(x: screen_width, y: 0, width: screen_width, height: toViewController.view.frame.size.height)
        
        // Configure Navi Transition
        
        var naviBarView:UIView!
        
        var toNaviLeft:UIView!
        var toNaviRight:UIView!
        var toNaviTitle:UIView!
        
        var fromNaviLeft:UIView!
        var fromNaviRight:UIView!
        var fromNaviTitle:UIView!
        
        if fromViewController.wb_navigationBarHidden || toViewController.wb_navigationBarHidden{}
        else{
            
            naviBarView = UIView(frame: CGRect(x: 0, y: 0, width: screen_width, height: 64))
            naviBarView.backgroundColor = UIColor(white: 1.0, alpha: 0.980)
            containerView.addSubview(naviBarView)
            
            let lineView=UIView(frame: CGRect(x: 0, y: 64, width: screen_width, height: 0.5))
            lineView.backgroundColor = UIColor(white: 0.869, alpha: 1.0)
            naviBarView.addSubview(lineView)
            
            toNaviLeft = toViewController.wb_navigationItem.leftBarButtonItem?.view
            toNaviRight = toViewController.wb_navigationItem.rightBarButtonItem?.view
            toNaviTitle = toViewController.wb_navigationItem.titleLabel
            
            fromNaviLeft = fromViewController.wb_navigationItem.leftBarButtonItem?.view
            fromNaviRight = fromViewController.wb_navigationItem.rightBarButtonItem?.view
            fromNaviTitle = fromViewController.wb_navigationItem.titleLabel
            
            
            // add to containerView
            
            if let toTitle = toNaviTitle {
                containerView.addSubview(toTitle)
                toTitle.alpha = 0.0
                toTitle.ve.center_x = 44
                toTitle.ve.center_x = screen_width
            }
            if let toLeft = toNaviLeft {
                containerView.addSubview(toLeft)
                toLeft.alpha = 0.0
                toLeft.ve.x = 0
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
                toLeft.ve.x = 0
            }
            if let toRight = toNaviRight {
                toRight.alpha = 1.0
                toRight.ve.x = self.screen_width - toRight.ve.width
            }
            
        }) { (finished) in
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            naviBarView.removeFromSuperview()
            
            if let fromTitle = fromNaviTitle {
                fromTitle.alpha = 1.0
                fromTitle.ve.center_x = self.screen_width / 2
                fromTitle.removeFromSuperview()
                fromViewController.wb_navigationBar.addSubview(fromTitle)
            }
            if let fromLeft = fromNaviLeft {
                fromLeft.alpha = 1.0
                fromLeft.ve.x = 0
                fromLeft.removeFromSuperview()
                fromViewController.wb_navigationBar.addSubview(fromLeft)
            }
            if let fromRight = fromNaviRight {
                fromRight.alpha = 1.0
                fromRight.ve.x = self.screen_width - fromRight.ve.width
                fromRight.removeFromSuperview()
                fromViewController.wb_navigationBar.addSubview(fromRight)
            }
            
            
            if let toTitle = toNaviTitle {
                toTitle.removeFromSuperview()
                toViewController.wb_navigationBar.addSubview(toTitle)
            }
            if let toLeft = toNaviLeft {
                toLeft.removeFromSuperview()
                toViewController.wb_navigationBar.addSubview(toLeft)
            }
            if let toRight = toNaviRight {
                toRight.removeFromSuperview()
                toViewController.wb_navigationBar.addSubview(toRight)
            }
            
        }
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.3
    }
}
