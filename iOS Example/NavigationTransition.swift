//
//  NavigationTransition.swift
//  Transition
//
//  Created by Konstantin Tsistjakov on 24/01/2017.
//  Copyright © 2017 Chipp Studio. All rights reserved.
//

import UIKit
import Transition

class NavigationTransition: Transition {
    
    // MARK: - Prepare transition
    override func prepareTransition() {
        self.setGesture()
    }
    
    // MARK: - Animations
    func presentAnimation(interactive: Bool) {
        var frame = self.toViewController.view.frame
        frame.origin.x = self.containerView.frame.size.width
        self.toViewController.view.frame = frame
        self.containerView.addSubview(self.toViewController.view)
        self.containerView.backgroundColor = UIColor.white
        
        UIView.animateKeyframes(withDuration: self.transitionDuration, delay: 0.0, options: UIViewKeyframeAnimationOptions.allowUserInteraction, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
                self.fromViewController.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                var newFrame = self.toViewController.view.frame
                newFrame.origin.x = 0.0
                self.toViewController.view.frame = newFrame
            })
            
        }) { (done) in
            self.fromViewController.view.transform = CGAffineTransform.identity
            self.transitionContext.completeTransition(!self.transitionContext.transitionWasCancelled)
        }
    }
    
    func dismissAnimation(interactive: Bool) {
        self.containerView.insertSubview(self.toViewController.view, at: 0)
        self.toViewController.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.containerView.backgroundColor = UIColor.white
        
        UIView.animateKeyframes(withDuration: self.transitionDuration, delay: 0.0, options: .allowUserInteraction, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                var newFrame = self.fromViewController.view.frame
                newFrame.origin.x = self.containerView.frame.size.width
                self.fromViewController.view.frame = newFrame
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 1.0, animations: {
                self.toViewController.view.transform = CGAffineTransform.identity
            })
            
        }) { (done) in
            self.transitionContext.completeTransition(!self.transitionContext.transitionWasCancelled)
        }
    }
    
    // MARK: - Interactive back gesture
    func setGesture() {
        let pan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(swipeGestureAction(sender: )))
        pan.edges = UIRectEdge.left
        self.ownerController.view.addGestureRecognizer(pan)
    }
    
    fileprivate var gesterPercent: CGFloat = 0.0
    
    func swipeGestureAction(sender: UIScreenEdgePanGestureRecognizer) {
        switch sender.state {
        case .began:
            self.beginInteractiveDismissalTransition(completion: nil)
        case .changed:
            let translation = sender.translation(in: self.ownerController.view)
            self.gesterPercent = translation.x / self.containerView.bounds.size.width
            self.updateInteractiveDismissalTransaction(_toProgress: self.gesterPercent)
        default:
            if self.gesterPercent >= 0.5 {
                self.finishInteractiveDismissalTransaction()
            } else {
                self.cancelInteractiveDismissalTransaction()
            }
        }
    }
}
