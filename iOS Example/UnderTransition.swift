//
//  UnderTransition.swift
//  Transition
//
//  Created by Konstantin Tsistjakov on 26/01/2017.
//  Copyright © 2017 Chipp Studio. All rights reserved.
//

import UIKit
import Transition

class UnderTransition: Transition {
    
    override func prepareTransition() {
        self.ownerController.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGesterAction(sender:))))
    }
    
    func presentAnimation(interactive: Bool) {
        self.toViewController.view.frame = self.containerView.bounds
        self.containerView.insertSubview(self.toViewController.view, at: 0)
        
        UIView.animateKeyframes(withDuration: self.transitionDuration, delay: 0.0, options: .allowUserInteraction, animations: { 
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                var newFrame = self.fromViewController.view.frame
                newFrame.origin.y = self.containerView.frame.size.height
                self.fromViewController.view.frame = newFrame
            })
        }) { (done) in
            self.transitionContext.completeTransition(!self.transitionContext.transitionWasCancelled)
        }
    }
    
    func dismissAnimation(interactive: Bool) {
        var newFrame = self.containerView.frame
        newFrame.origin.y = self.containerView.frame.size.height
        self.toViewController.view.frame = newFrame
        self.containerView.addSubview(self.toViewController.view)
        
        UIView.animateKeyframes(withDuration: self.transitionDuration, delay: 0.0, options: .allowUserInteraction, animations: { 
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                var newFrame = self.containerView.bounds
                newFrame.origin.y = UIApplication.shared.isStatusBarHidden ? 0.0 : 20.0
                self.toViewController.view.frame = newFrame
            })
        }) { (done) in
            if !self.transitionContext.transitionWasCancelled {
                self.toViewController.view.frame = self.containerView.bounds
            }
            self.transitionContext.completeTransition(!self.transitionContext.transitionWasCancelled)
        }
    }
    
    fileprivate var updateProgress: CGFloat = 0.0
    func panGesterAction(sender: UIPanGestureRecognizer) {
        if sender.translation(in: self.ownerController.view).y > 0 {
            return
        }
        
        self.updateProgress = -sender.translation(in: self.ownerController.view).y / self.containerView.frame.size.height
        
        switch sender.state {
        case .began:
            self.beginInteractiveDismissalTransition(completion: nil)
        case .changed:
            self.updateInteractiveDismissalTransaction(_toProgress: updateProgress)
        default:
            if self.updateProgress > 0.5 {
                self.finishInteractiveDismissalTransaction()
            } else {
                self.cancelInteractiveDismissalTransaction()
            }
        }
    }
}
