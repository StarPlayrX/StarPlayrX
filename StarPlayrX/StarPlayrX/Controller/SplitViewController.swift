//
//  SplitViewController.swift
//  StarPlayrX
//
//  Created by Todd Bruss on 4/11/20.
//  Copyright © 2020 Todd Bruss. All rights reserved.
//


import UIKit


class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .bottom }
    override var prefersHomeIndicatorAutoHidden : Bool { return true }
    override var prefersStatusBarHidden: Bool { return false }
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        self.delegate = self
        self.preferredDisplayMode = .allVisible
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        if let appearance = navigationController?.navigationBar.standardAppearance {
            appearance.shadowImage = nil
            appearance.shadowColor = UIColor(displayP3Red: 20 / 255, green: 22 / 255, blue: 24 / 255, alpha: 1.0)
            appearance.backgroundColor = UIColor(displayP3Red: 20 / 255, green: 22 / 255, blue: 24 / 255, alpha: 1.0)
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.layer.borderWidth = 0.0
        }
        
    }
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
}
