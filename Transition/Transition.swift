//
//  Transition.swift
//  Transition
//
//  Created by Konstantin Tsistjakov on 24/01/2017.
//  Copyright © 2017 Chipp Studio. All rights reserved.
//

import UIKit

@objc protocol TransitionAnimationsProtocol: NSObjectProtocol {
    @objc optional func presentAnimation(interactive: Bool)
    @objc optional func dismissAnimation(interactive: Bool)
}

open class Transition: NSObject, TransitionAnimationsProtocol {
    
    // MARK: - Private(set) variables
    fileprivate(set) var transitionDuration: TimeInterval = 0.3
    fileprivate(set) var transitionContext: UIViewControllerContextTransitioning!
    fileprivate(set) var containerView: UIView!
    fileprivate(set) var toViewController: UIViewController!
    fileprivate(set) var fromViewController: UIViewController!
    fileprivate(set) var isPresenting: Bool = true
    fileprivate(set) var ownerController: UIViewController!
    
    // MARK: - Private
    fileprivate var interactionDismissalController: UIPercentDrivenInteractiveTransition!
    
    // MARK: - Init
    init(animationDuration duration: TimeInterval) {
        super.init()
        self.transitionDuration = duration
    }
}

// MARK: - UIViewControllerAnimatedTransitioning
extension Transition: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.transitionDuration
    }
    
    public func animateTransition(using context: UIViewControllerContextTransitioning) {
        
        self.toViewController = context.viewController(forKey: UITransitionContextViewControllerKey.to)
        self.fromViewController = context.viewController(forKey: UITransitionContextViewControllerKey.from)
        self.containerView = context.containerView
        self.transitionContext = context
        
        if self.isPresenting {
            (self as TransitionAnimationsProtocol).presentAnimation?(interactive: context.isInteractive)
        } else {
            (self as TransitionAnimationsProtocol).dismissAnimation?(interactive: context.isInteractive)
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension Transition: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if !self.responds(to: #selector(TransitionAnimationsProtocol.presentAnimation(interactive: ))) {
            return nil
        }
        
        self.isPresenting = true
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        self.addFinalSetupToDismissedViewController(dismissed: dismissed)
        
        if !self.responds(to: #selector(TransitionAnimationsProtocol.dismissAnimation(interactive: ))) {
            return nil
        }
        
        self.isPresenting = false
        return self
    }
    
    // http://openradar.appspot.com/radar?id=5320103646199808
    private func addFinalSetupToDismissedViewController(dismissed: UIViewController) {
        if dismissed.modalPresentationStyle == .fullScreen || dismissed.modalPresentationStyle == .currentContext {
            return
        }
        
        // Adding to main thread queue, becase when this method get called `transitionCoordinator` is nil
        OperationQueue.main.addOperation {
            dismissed.transitionCoordinator?.animate(alongsideTransition: nil, completion: { (context) in
                if !context.isCancelled {
                    let toViewController = context.viewController(forKey: UITransitionContextViewControllerKey.to)
                    UIApplication.shared.keyWindow?.addSubview(toViewController!.view)
                }
            })
        }
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactionDismissalController
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return nil
    }
}

// MARK: - Interactive dissmiss
extension Transition {
    func beginInteractiveDismissalTransition(completion: (() -> Void)?) {
        self.interactionDismissalController = UIPercentDrivenInteractiveTransition()
        self.ownerController.dismiss(animated: true, completion: completion)
    }
    
    func updateInteractiveDismissalTransaction(_toProgress progress: CGFloat) {
        self.interactionDismissalController.update(progress)
    }
    
    func cancelInteractiveDismissalTransaction() {
        // http://openradar.appspot.com/14675246
        self.interactionDismissalController.completionSpeed = 0.999 // http://stackoverflow.com/a/22968139/188461
        self.interactionDismissalController.cancel()
        
        self.interactionDismissalController = nil
    }
    
    func finishInteractionDismissalTransaction() {
        self.interactionDismissalController.finish()
        self.interactionDismissalController = nil
    }
}

// MARK: - UIViewController Extension

private var transitionAssociatedObject: UInt8 = 0

public extension UIViewController {
    public var transition: Transition? {
        get {
            return objc_getAssociatedObject(self, &transitionAssociatedObject) as? Transition
        }
        
        set {
            newValue?.ownerController = self
            self.transitioningDelegate = newValue
            objc_setAssociatedObject(self, &transitionAssociatedObject, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
