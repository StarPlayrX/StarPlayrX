//
//  AppDelegate.swift
//  StarPlayr
//
//  Created by Todd on 2/8/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import UIKit
import Foundation
import CameoKit


var mustLoginAgain = false
var startup = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
 
    
    var window: UIWindow?
    
     var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
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
    
    
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
 
        startup = true
        LaunchServer()
        
        ///
        /// Attention: This area causes simulator to crash.. Assuming it will also crash iOS 13. Removing it is the safest option -T.Bruss 7.22.19
        ///
        /// Override point for customization after application launch. I love this new comment style btw! Great job Apple! :) Seriously.
        ///
         let selectedView = UIView()
        selectedView.backgroundColor = UIColor(red: 29/255, green: 30/255, blue: 36/255, alpha: 1.0)
        UITableViewCell.appearance().selectedBackgroundView = selectedView
        /*
        
        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = UIColor(displayP3Red: 30 / 255, green: 32 / 255, blue: 34 / 255, alpha: 0.8)
        }
         */
 
       setupRemoteTransportControls(application: application)
       application.beginReceivingRemoteControlEvents()
 
    
        
        return true
    }
     
    func applicationWillResignActive(_ application: UIApplication) {
       /*
        channelList = nil
        channelData = nil
        
        if !player!.isPlaying {
            pdtTimer?.invalidate()
            pdtTimer = nil
            
            playerViewTimer?.invalidate()
            playerViewTimer = nil
        }*/

        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
      
        
        
    }
    

    func applicationWillEnterForeground(_ application: UIApplication) {
        
      

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
       
        if let starplayr = player {
            if !starplayr.isReady {
                networkIsTripped = true
                autoLaunchServer(play:false)
                NotificationCenter.default.post(name: .didUpdatePause, object: nil)
            }
        }
        
        /*
        if !player!.isPlaying {
            pdtTimer?.invalidate()
            pdtTimer = nil
            
            playerViewTimer?.invalidate()
            playerViewTimer = nil
        }*/
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        channelList = nil
        channelData = nil
    
        pdtTimer?.invalidate()
        pdtTimer = nil
        
        playerViewTimer?.invalidate()
        playerViewTimer = nil
        
        data = nil
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /*
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void) {
        //Future update icons
        let pingUrl = "http://localhost:" + String(Global.variable.port) + "/ping"
        _ = TextSync(endpoint: pingUrl, method: "ping")
        completionHandler(.newData)
    }*/
    
}


