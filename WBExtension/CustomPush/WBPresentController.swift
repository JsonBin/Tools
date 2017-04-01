//
//  WBPresentController.swift
//  WBExtension
//
//  Created by zwb on 17/2/27.
//  Copyright © 2017年 HengSu Technology. All rights reserved.
//

import UIKit

// MARK: -

/// 自定义模态推送(高斯模糊当前页面为背景图)
public class WBPresentController: UIViewController {
    
    /// 高斯模糊的style
    public var blurStyle: UIBlurEffectStyle?
    {
        didSet{
            if blurStyle != oldValue{
                presenter?.blurStyle = blurStyle
            }
        }
    }
    
    /// private property
    private var presenter: WBBlurPresenter?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        wb_commonSetup()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        wb_commonSetup()
    }

    /// viewDidLoad
    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// 设置默认属性
    private func wb_commonSetup() {
        
        modalPresentationStyle = .custom
        
        presenter = WBBlurPresenter()
        blurStyle = .dark
        presenter?.blurStyle = blurStyle
        
        transitioningDelegate = presenter
    }

}

// MARK: - UIPresentationController

/// 重写UIPresentationController类
public class WBBlurPresentationController : UIPresentationController {
    
    /// 设置高斯模糊的系统属性style
    public var blurStyle: UIBlurEffectStyle?
    {
        didSet{
            if blurStyle != oldValue {
                let previousDimmingView = dismissView
                let effect = UIBlurEffect(style: blurStyle!)
                dismissView = UIVisualEffectView(effect: effect)
                let subviews = effectView?.subviews
                guard let views = subviews else {
                    fatalError("Custom Present views count is 0. [\(#file)].[\(#line)]:\(#function)")
                }
                for view in views {
                    if view == previousDimmingView {
                        dismissView?.frame = previousDimmingView!.frame
                        effectView?.insertSubview(dismissView!, aboveSubview: previousDimmingView!)
                        previousDimmingView?.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    /// 实现响应协议
    public var wb_presentDelegate: WBBlurPresentationControllerDelegate?
    
    private var effectView: UIView?
    private var dismissView: UIVisualEffectView?
    
    /// init 重构
    ///
    /// - Parameters:
    ///   - presentedViewController: presented vc
    ///   - presentingViewController: presenting vc
    ///   - style: UIBlurEffectStyle
    public convenience init(_ presentedViewController:UIViewController, presenting presentingViewController:UIViewController?, blurStyle style:UIBlurEffectStyle) {
        
        self.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        let effect = UIBlurEffect(style: style)
        dismissView = UIVisualEffectView(effect: effect)
        blurStyle = style
        effectView = UIView()
        effectView?.alpha = 0.0
        
        delegate = self
    }
    
    /// 将要开始present
    public override func presentationTransitionWillBegin() {
        
        effectView?.frame = containerView!.bounds
        dismissView?.frame = containerView!.bounds
        
        effectView?.insertSubview(dismissView!, at: 0)
        containerView?.insertSubview(effectView!, at: 0)
        
        effectView?.alpha = 0.0
        
        let coordinator = presentedViewController.transitionCoordinator
        if coordinator != nil {
            coordinator?.animate(alongsideTransition: { [weak self] (context) in
                self!.effectView?.alpha = 1.0
            }, completion: nil)
        }else{
            effectView?.alpha = 1.0
        }
    }
    
    /// 将要dismiss
    public override func dismissalTransitionWillBegin() {
        
        let coordinator = presentedViewController.transitionCoordinator
        if coordinator != nil {
            coordinator?.animate(alongsideTransition: { [weak self] (context) in
                self!.effectView?.alpha = 0.0
            }, completion: nil)
        }else{
            effectView?.alpha = 0.0
        }
    }
    
    /// 已经dismiss
    ///
    /// - Parameter completed: 是否结束
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            wb_presentDelegate?.presentationControllerDidDismissed(self)
        }
    }
    
    public override func containerViewWillLayoutSubviews() {
        effectView?.frame = containerView!.bounds
        dismissView?.frame = containerView!.bounds
        presentedView?.frame  = containerView!.bounds
    }
    
}

// MARK: - 实现协议，响应自定义推送

extension WBBlurPresentationController: UIAdaptivePresentationControllerDelegate {
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .custom
    }
}

// MARK: - 提供协议，完成推送后的方法

public protocol WBBlurPresentationControllerDelegate {
    
    func presentationControllerDidDismissed(_ controller:WBBlurPresentationController) -> Void
}

// MARK: - 实现自定义转场协议

/// 自定义转场协议
public class WBBlurPresenter: NSObject, UIViewControllerTransitioningDelegate {
    
    /// 模糊效果
    public var blurStyle: UIBlurEffectStyle?
    {
        didSet{
            if blurStyle != oldValue {
                animationController?.blurStyle = blurStyle
            }
        }
    }
    
    /// 私有属性，为extension调用
    public var isPresentation: Bool = false
    
    /// 动画的vc
    public var animationController: WBBlurPresentationController?
    
    /// 初始化，设置默认属性
    override init() {
        super.init()
        
        blurStyle = .dark
    }
    
    /// 重写系统转场动画
    ///
    /// - Parameters:
    ///   - presented: presented vc
    ///   - presenting: presenting vc
    ///   - source: source vc
    /// - Returns: UIPresentationController
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        if animationController == nil {
            animationController = WBBlurPresentationController(presented, presenting: presenting, blurStyle: blurStyle!)
            animationController?.wb_presentDelegate = self
        }
        return animationController
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresentation = true
        
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresentation = false
        
        return self
    }
}

// MARK: - Extension WBBlurPresenter

extension WBBlurPresenter: WBBlurPresentationControllerDelegate {
    
    public func presentationControllerDidDismissed(_ controller: WBBlurPresentationController) {
        animationController = nil
    }
}

// MARK: - 实现转场动画

extension WBBlurPresenter : UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        
        let fromView = fromViewController.view!
        let toView = toViewController.view!
        
        let containerView = transitionContext.containerView
        if isPresentation {
            containerView.addSubview(toView)
        }
        
        let animatingViewController = isPresentation ? toViewController : fromViewController
        let animatingView = isPresentation ? toView : fromView
        
        let onScreenFrame = transitionContext.finalFrame(for: animatingViewController)
        let offScreenFrame = onScreenFrame.offsetBy(dx: 0, dy: onScreenFrame.size.height)
        
        let initialFrame = isPresentation ? offScreenFrame : onScreenFrame
        let finalFrame = isPresentation ? onScreenFrame : offScreenFrame
        animatingView.frame = initialFrame
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 300.0, initialSpringVelocity: 5.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            animatingView.frame = finalFrame
        }) { (finished) in
            if !self.isPresentation {
                fromView.removeFromSuperview()
            }
            transitionContext.completeTransition(true)
        }
    }
}
