//
//  TabViewController.swift
//  StarPlayr
//
//  Created by Todd Bruss on 2/10/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import UIKit

class TabController: UITabBarController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        
    }
    
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        let deviceType = UIDevice().type
        
        // iPhoneX which is portrait only
        if deviceType == .iPhoneX || deviceType == .iPhoneXSMax {
            return .portrait
        }
        
        // All other iPhone screen sizes
        if deviceType == .iPhone8 || deviceType == .iPhone8Plus || deviceType == .iPhoneSE {
            return [.portrait,.portraitUpsideDown] //brings back upsidedown on non-iPhoneX's
            
        } else if deviceType == .iPad {
            return .landscape
        } else {
            return .all // don't know what device that have, but it will still work just not optimized
        }
    }

}

//TabViewController
extension TabController: UITabBarControllerDelegate  {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false // Make sure you want this as false
        }
        
        if fromView != toView {
            UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
        }
        
        
        return true
    }
}

