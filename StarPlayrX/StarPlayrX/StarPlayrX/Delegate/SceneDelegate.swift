//
//  SceneDelegate.swift
//  StarPlayrX
//
//  Created by Todd Bruss on 4/19/20.
//  Copyright © 2020 Todd Bruss. All rights reserved.
//

import UIKit

var isMacCatalystApp = false

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate  {
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        if ProcessInfo.processInfo.isMacCatalystApp {
            isMacCatalystApp = true
            UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
                windowScene.sizeRestrictions?.minimumSize = CGSize(width: 1364.5, height: 1023.5)
                windowScene.sizeRestrictions?.maximumSize = CGSize(width: 1364.5, height: 1023.5)
           }
        }


        #if targetEnvironment(macCatalyst)
           guard let windowScene = (scene as? UIWindowScene) else { return }
           if let titlebar = windowScene.titlebar {
               titlebar.titleVisibility = .hidden
               titlebar.toolbar = nil
           }
        #endif
    }
}
