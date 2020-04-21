//
//  Extensions.swift
//  StarPlayr
//
//  Created by Todd on 3/2/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import CameoKit

extension UIImage {
    func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return self }
        defer { UIGraphicsEndImageContext() }
        
        let rect = CGRect(origin: .zero, size: size)
        ctx.setFillColor(color.cgColor)
        ctx.fill(rect)
        ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
        ctx.draw(cgImage!, in: rect)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}


//Some extra variables, so we can check the status of our AVPlayer
extension AVQueuePlayer {
    
    var isReady: Bool {
        let pingUrl = "http://localhost:" + String(Player.shared.port) + "/ping"
        let ping = TextSync(endpoint: pingUrl, method: "ping")
        if ping == "pong" {
            return true
        } else {
            return false
        }
    }
    
    var isTwin: Bool {
        return lastchannel == currentChannel
    }
    
    var isDead: Bool {
        return rate == 0 || currentItem == .none || error != nil
    }
    
    var isBusy: Bool {
        return rate == 1 && currentItem != .none && error == nil
    }
}


extension Notification.Name {
    static let didUpdatePlay = Notification.Name("didUpdatePlay")
    static let didUpdatePause = Notification.Name("didUpdatePause")
    static let gotNowPlayingInfo = Notification.Name("gotNowPlayingInfo")
    static let gotSessionInterruption = AVAudioSession.interruptionNotification
    static let gotRouteChangeNotification = AVAudioSession.routeChangeNotification
    static let gotVolumeDidChange = NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification")
    static let willEnterForegroundNotification = UIApplication.willEnterForegroundNotification
}
