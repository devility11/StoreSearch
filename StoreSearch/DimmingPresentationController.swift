//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Norbert Czirjak on 2017. 11. 15..
//  Copyright © 2017. Norbert Czirjak. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    //this will leave the searchviewvontroller visible when we tap on a row,
    //to get the detail view popup
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    //the gradient view will have the same size as the frame
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    //this will be called when the new view will loaded to the view
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds
        //with this i just simply adding the new gradient view from the top
        containerView!.insertSubview(dimmingView, at: 0)
        
        dimmingView.alpha = 0
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 1
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0
            }, completion: nil)
        }
    }
    
    
}
