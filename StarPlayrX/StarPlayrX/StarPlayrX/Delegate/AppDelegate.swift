//
//  AppDelegate.swift
//  StarPlayrX
//
//  Created by Todd Bruss on 4/19/20.
//  Copyright © 2020 Todd Bruss. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {        
      //  let net = Network.ability
        
       // net.start()
        //net.LaunchServer()
        
        // Override point for customization after application launch.
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(displayP3Red: 20 / 255, green: 22 / 255, blue: 24 / 255, alpha: 1.0)
        UITableViewCell.appearance().selectedBackgroundView = selectedView
        
        Player.shared.setupRemoteTransportControls(application: application)
        application.beginReceivingRemoteControlEvents()

        return true
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
