//
//  PlayStream.swift
//  StarPlayr
//
//  Created by Todd on 3/1/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation
import CameoKit
import AVKit
import MediaPlayer
import MediaAccessibility
import PerfectHTTPServer
import PerfectHTTP

var player : AVPlayer? = AVPlayer()
var gSliderVolume : Float? = 1.000
var gURL = URL(string:"")

func PlayStream(volume: Float) {
    
        if let starplayr = player , let user = userid {
            if starplayr.isReady {
                
                //PlayerQueue.async {
                    if let url = URL(string: insecure + local + ":" + String(port) + "/playlist/" + user + "/" + currentChannel + m3u8) {
                        player = AVPlayer(url: url)
                    }
                    
                    player?.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = false
                    player?.volume = volume
                    player?.play()
                    networkIsTripped = false
                    NotificationCenter.default.post(name: .didUpdatePlay, object: nil)
                //}
                
            } else {
                startup = true
                autoLaunchServer(play: true)
            }
        }
    
}

public let PlayerQueue = DispatchQueue(label: "PlayerQueue", qos: .background )


func magicTapped() {
    playPause()
}

func Pause() {
    if let _ = player {
        
        //load up a non audio file
        guard let path = Bundle.main.path(forResource: "no-audio", ofType: "m4a") else {
            return
        }
        
        let url = NSURL(fileURLWithPath: path)
        player = AVPlayer(url: url as URL)

        // Create an AVPlayer, passing it the local video url path
        player?.pause()
    
        NotificationCenter.default.post(name: .didUpdatePause, object: nil)
    }
}

func Play() {
    if let starplayr = player {
        starplayr.play()
        NotificationCenter.default.post(name: .didUpdatePlay, object: nil)
    }
}

func autoLaunchServer(play: Bool) {
    print("Restarting Server")
    
    if UIAccessibility.isVoiceOverRunning {
        let utterance = AVSpeechUtterance(string: "Buffering")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    do {
        //Find the first Open port
        for i in port...64999 {
            let (isFree, _) = checkTcpPortForListen(port: UInt16(i))
            if isFree {
                port = UInt16(i)
                break;
            }
        }
        
        let server = HTTPServer.Server(name: localhost, address: local, port: Int(port), routes: routes() )
        try HTTPServer.launch(wait: false, server)
        
        //PlayerQueue.async {
            if let volume = gSliderVolume {
                
                if play {
                    PlayStream(volume: volume)
                    NotificationCenter.default.post(name: .didUpdatePlay, object: nil)
                }
            }
        //}
    } catch {
        print(error)
    }
}


func playPause() {
    if let starplayr = player {
        
        if starplayr.isBusy {
            Pause()
        } else if let volume = gSliderVolume {
            PlayStream(volume: volume)
            lastchannel = currentChannel
        }
    }
}


extension AVPlayer {
    
    var readyToPlay : Bool {
        return status == .readyToPlay
    }
    
    var hasItem : Bool {
        return currentItem != nil
    }
    
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
    
    var isReady: Bool {
        let pingUrl = "http://localhost:" + String(port) + "/ping"
        let ping = TextSync(endpoint: pingUrl, method: "ping")
        var ready = false
        if ping == "pong" {
            ready = true
        } else {
            ready = false
        }
        
        if !ready {
            let avp : AVPlayerItem? = nil
            
            replaceCurrentItem(with: avp )
        }
        return ready
    }
    
    var isTwin: Bool {
        //print(lastchannel, currentChannel)
        
        return lastchannel == currentChannel
    }
    
    var isOnPause: Bool {
        return !isPlaying || networkIsTripped
    }
    
    var isBusy: Bool {
        return readyToPlay && isPlaying && isReady && hasItem && isTwin && !networkIsTripped
    }
}


extension Notification.Name {
    static let didPlayPause = Notification.Name("didPlayPause")
    static let didUpdatePlay = Notification.Name("didUpdatePlay")
    static let didUpdatePause = Notification.Name("didUpdatePause")
    static let gotNowPlayingInfo = Notification.Name("gotNowPlayingInfo")
    static let didStartPlaying = Notification.Name("didStartPlaying")
    static let gotSessionInterruption = AVAudioSession.interruptionNotification
}



func setupRemoteTransportControls(application: UIApplication) {
    do {
        let avsi = AVAudioSession.sharedInstance()
        avsi.accessibilityPerformMagicTap()
        avsi.accessibilityActivate()
        try avsi.setCategory(.playback, mode: .moviePlayback, options: [])
        try avsi.setActive(true)
        
    } catch {
        print("Did Not Play")
        print(error)
    }
    
    // Get the shared MPRemoteCommandCenter
    let commandCenter = MPRemoteCommandCenter.shared()
    
    commandCenter.accessibilityActivate()
    
   
    
    
     commandCenter.playCommand.addTarget(handler: { (event) in    // Begin playing the current track
        playPause()
        return MPRemoteCommandHandlerStatus.success}
     )
     
     commandCenter.pauseCommand.addTarget(handler: { (event) in    // Begin playing the current track'
        playPause()

        
     return MPRemoteCommandHandlerStatus.success}
     )
    
    
    commandCenter.togglePlayPauseCommand.addTarget(handler: { (event) in    // Begin playing the current track
        playPause()
        
        return MPRemoteCommandHandlerStatus.success}
    )
    
}


