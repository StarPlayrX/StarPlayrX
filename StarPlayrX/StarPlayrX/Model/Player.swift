//
//  PlayStream.swift
//  StarPlayr
//
//  Created by Todd on 3/1/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation
import CameoKit
import MediaPlayer
import PerfectHTTPServer
import CryptoKit

final class Player {
    static let shared = Player()
    
    let g = Global.obj
    
    public let PlayerQueue = DispatchQueue(label: "PlayerQueue", qos: .userInitiated )
    public let PDTqueue = DispatchQueue(label: "PDT", qos: .userInteractive, attributes: .concurrent)
    
    var player = AVQueuePlayer()
    var port: UInt16 = 9999
    var everything = "All Channels"
    var allStars = "All Stars"
    var SPTableDataX = tableData()
    var SPXPresets = [String]()
    var pdtCache =  [String : Any]()
    var localChannelArt = ""
    var localAlbumArt = ""
    var preArtistSong = ""
    var setAlbumArt = false
    var maxAlbumAttempts = 3
    var state : PlayerState? = nil
    
    
    func resetAirPlayVolumeX() {
        if avSession.currentRoute.outputs.first?.portType == .airPlay {
            DispatchQueue.main.async {
                //AP2Volume.shared()?.setVolumeBy(0.0)
            }
        }
    }
    
    func new(_ state: PlayerState? = nil) {
        if state == .stream {
            player.pause()
            self.playX()
        } else if player.rate == 1 || self.state == .playing {
            self.pause()
            self.state = .paused
        } else {
            self.playX()
            self.state = .buffering
        }
    }
    
    
    //MARK: Update the screen
    func syncArt() {
        
        if let md5 = self.MD5(String(CACurrentMediaTime().description)) {
            self.previousMD5 = md5
        } else {
            let str = "Hello, Last Star Player X."
            self.previousMD5 = self.MD5(String(str)) ?? str
        }
        
        if g.Server.isReady {
            if let i = g.ChannelArray.firstIndex(where: {$0.channel == g.currentChannel}) {
                let item = g.ChannelArray[i].largeChannelArtUrl
                self.updateDisplay(key: g.currentChannel, cache: self.pdtCache, channelArt: item, false)
            }
        }
    }
    
    
    func playX() {
        let g = Global.obj
        
        NotificationCenter.default.post(name: .didUpdatePlay, object: nil)
        state = .buffering
        
        func stream() {
            if self.player.isDead  {
                resetPlayer()
            }
            
            if g.Server.isReady {
                
                if let url = URL(string: g.insecure + g.local +
                    ":" + String(port) + "/playlist/" + g.currentChannel + g.m3u8) {
                    
                    let asset = AVAsset(url: url)
                    let playItem = AVPlayerItem(asset:asset)
                    let p = self.player
                    p.insert(playItem, after: nil)
                    p.automaticallyWaitsToMinimizeStalling = true
                    p.allowsExternalPlayback = false
                    p.appliesMediaSelectionCriteriaAutomatically = true
                    p.currentItem?.preferredForwardBufferDuration = 0
                    p.currentItem?.automaticallyPreservesTimeOffsetFromLive = true
                    p.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + avSession.outputLatency) {
                        p.playImmediately(atRate: 1.0)
                        self.state = .playing
                        p.currentItem?.preferredForwardBufferDuration = 1
                    }
                }
            }
        }
        
        //MARK: Stop the player, we have an issue - this could show an interruption
        func stop() {
            self.player.pause()
            self.state = .paused
            NotificationCenter.default.post(name: .didUpdatePause, object: nil)
            self.resetPlayer()
            self.player = AVQueuePlayer()
        }
        
        //MARK: Launch Server and Stream
        func launchServer() {
            autoLaunchServer(completionHandler: { (success) -> Void in
                success ? stream() : stop()
            })
        }
        
        g.Server.isReady ? stream() : launchServer()
        
    }
    
    func change() {
        self.player.currentItem?.preferredForwardBufferDuration = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + avSession.outputLatency) {
            self.player.currentItem?.preferredForwardBufferDuration = 1
        }
    }
    
    func runReset(starplayrx: AVPlayerItem) {
        starplayrx.asset.cancelLoading()
        player.remove(starplayrx)
        player.replaceCurrentItem(with: nil)
    }
    
    func resetPlayer() {
        
        if !player.items().isEmpty {
            
            let count = player.items().count
            if count == 1 {
                if let starplayrx = self.player.items().first as AVPlayerItem? {
                    runReset(starplayrx: starplayrx)
                }
            } else if count > 1 {
                
                for starplayrx in player.items() {
                    runReset(starplayrx: starplayrx)
                }
            }
        }
        
    }
    
    
    func pause() {
        self.player.pause()
        self.state = .paused
        NotificationCenter.default.post(name: .didUpdatePause, object: nil)
        self.resetPlayer()
        self.player = AVQueuePlayer()
    }
    
    
    
    
    var previousMD5 = "reset"
    
    //MARK: New and Improved MD5
    func MD5(_ d: String) -> String? {
        
        var str = String()
        
        for byte in Insecure.MD5.hash(data: d.data(using: .utf8) ?? Data() ) {
            str += String(format: "%02x", byte)
        }
        
        return str
    }
    
    //MARK: Update our display
    func updateDisplay(key: String, cache: [String : Any], channelArt: String, _ animated: Bool = true) {
        if let value  = cache[key] as? [String: String],
            let artist = value["artist"] as String?,
            let song   = value["song"] as String?,
            let image  = value["image"] as String?,
            let md5 = MD5(artist + song + key + channelArt + image),
            previousMD5 != md5
        {
            
            previousMD5 = md5
            g.NowPlaying.artist = artist
            g.NowPlaying.song = song
            g.NowPlaying.channel = key
            g.NowPlaying.channelArt = channelArt
            g.NowPlaying.albumArt = image
            updateNowPlayingX(animated)
        }
    }
    
    public func chooseFilter(fileName:String, values:[Float],filterKeys:[String],image:UIImage) -> UIImage {
        let context = CIContext()
        let filter = CIFilter(name: fileName)
        for i in 0..<filterKeys.count {
            filter?.setValue(values[i], forKey:filterKeys[i])
        }
        filter?.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        let result = filter?.outputImage
        if let cgimage = context.createCGImage(result!, from: result!.extent) {
            return UIImage(cgImage: cgimage)
        }
        
        return image
    }
    
    public func chooseFilterCategories(name:String,values:[Float],filterKeys:[String],image:UIImage) -> UIImage {
        let filters = CIFilter.filterNames(inCategory: name)
        for filter in filters {
            if filter == "CIUnsharpMask" {
                let newImage = self.chooseFilter(fileName: filter, values: values, filterKeys: filterKeys, image: image)
                return newImage
            }
        }
        
        return image
    }
    
    //loading the album art
    //MARK: Todd
    func updateNowPlayingX(_ animated: Bool = true) {
        
        let g = Global.obj
        
        func demoImage() -> UIImage? {
            
            if var img = UIImage(named: "starplayr_placeholder") {
                img = img.withBackground(color: UIColor(displayP3Red: 19 / 255, green: 20 / 255, blue: 36 / 255, alpha: 1.0))
                img = self.resizeLargeImage(image: img, targetSize: CGSize(width: 1440, height: 1440))
                return img
            } else {
                return nil
            }
        }
        
        
        func displayArt(image: UIImage?) {
            if var img = image {
                img = img.withBackground(color: UIColor(displayP3Red: 19 / 255, green: 20 / 255, blue: 36 / 255, alpha: 1.0))
                img = self.resizeLargeImage(image: img, targetSize: CGSize(width: 720, height: 720))
                img = self.chooseFilterCategories(name: kCICategorySharpen, values: [0.0625,0.125], filterKeys: [kCIInputRadiusKey,kCIInputIntensityKey], image: img)
                img = self.resizeLargeImage(image: img, targetSize: CGSize(width: 1080, height: 1080))
                img = self.chooseFilterCategories(name: kCICategorySharpen, values: [0.125,0.25], filterKeys: [kCIInputRadiusKey,kCIInputIntensityKey], image: img)
                img = self.resizeLargeImage(image: img, targetSize: CGSize(width: 1440, height: 1440))
                img = self.chooseFilterCategories(name: kCICategorySharpen, values: [0.25,0.5], filterKeys: [kCIInputRadiusKey,kCIInputIntensityKey], image: img)
                g.NowPlaying.image = img
                self.setnowPlayingInfo(channel: g.NowPlaying.channel, song: g.NowPlaying.song, artist: g.NowPlaying.artist, imageData:img)
                
            } else if let i = demoImage()  {
                g.NowPlaying.image = i
                self.setnowPlayingInfo(channel: g.NowPlaying.channel, song: g.NowPlaying.song, artist: g.NowPlaying.artist, imageData: i)
            }
            
            if animated {
                DispatchQueue.main.async { NotificationCenter.default.post(name: .gotNowPlayingInfoAnimated, object: nil) }
                
            } else {
                DispatchQueue.main.async { NotificationCenter.default.post(name: .gotNowPlayingInfo, object: nil) }
            }
            
        }
        
        
        
        //Demo Mode
        if !g.demomode {
            
            //Get album art
            if g.NowPlaying.albumArt.contains(string: "http") {
                Async.api.Imagineer(endpoint: g.NowPlaying.albumArt, ImageHandler: { (img) -> Void in
                    displayArt(image: img)
                })
            } else {
                Async.api.Imagineer(endpoint: g.NowPlaying.channelArt, ImageHandler: { (img) -> Void in
                    displayArt(image: img)
                })
            }
            
        } else {
            displayArt(image: demoImage()! )
        }
        
    }
    
    
    func resizeLargeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        
        UIGraphicsBeginImageContextWithOptions( targetSize, false, 1.0)
        
        image.draw(in: rect)
        
        if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return newImage
        }
        
        return UIImage()
    }
    
    
    
    //MARK: Update Artist Song Info
    func updatePDT(completionHandler: @escaping CompletionHandler ) {
        if g.Server.isReady {
            
            let g = Global.obj
            
            let endpoint = g.insecure + g.local + ":" + String(self.port) + "/pdt"
            
            Async.api.Get(endpoint: endpoint, DictionaryHandler: { (dict) -> Void in
                
                if let p = dict as? [String : Any], !p.isEmpty, let cache = p["data"] as? [String : Any], !cache.isEmpty {
                    self.pdtCache = cache
                    
                    g.ChannelArray = self.getPDTData(importData: g.ChannelArray)
                    completionHandler(true)
                    
                } else {
                    completionHandler(false)
                }
            })
        }
    }
    
    
    //MARK: Update Artist Song Info
    func updatePDT_skipCheck(completionHandler: @escaping CompletionHandler ) {
        let g = Global.obj
        
        let endpoint = g.insecure + g.local + ":" + String(self.port) + "/pdt"
        
        Async.api.Get(endpoint: endpoint, DictionaryHandler: { (dict) -> Void in
            
            if let p = dict as? [String : Any], !p.isEmpty, let cache = p["data"] as? [String : Any], !cache.isEmpty {
                self.pdtCache = cache
                
                g.ChannelArray = self.getPDTData(importData: g.ChannelArray)
                completionHandler(true)
                
            } else {
                completionHandler(false)
            }
        })
    }
    
    
    func getPDTData(importData: tableData) -> tableData {
        var nowPlayingData = importData
        
        for i in 0..<nowPlayingData.count {
            
            let key = nowPlayingData[i].channel
            
            if let value = pdtCache[key] as? [String: String], let artist = value["artist"] as String?, let song = value["song"]  as String?, let image = value["image"]  as String? {
                
                let setArtist = NSMutableAttributedString(string: artist + "\n" , attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]);
                let setSong = NSMutableAttributedString(string: song, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]);
                
                setArtist.append(setSong)
                
                nowPlayingData[i].detail = setArtist
                nowPlayingData[i].largeAlbumUrl = image
                nowPlayingData[i].searchString = nowPlayingData[i].title.string
                nowPlayingData[i].searchString = nowPlayingData[i].searchString + " " + artist
                nowPlayingData[i].searchString = nowPlayingData[i].searchString + " " + song
                nowPlayingData[i].searchString = nowPlayingData[i].searchString.replacingOccurrences(of: "'", with: "")
                nowPlayingData[i].image = nowPlayingData[i].channelImage
                nowPlayingData[i].albumUrl =  nowPlayingData[i].largeChannelArtUrl
            }
        }
        
        return nowPlayingData
        
    }
    
    public func setnowPlayingInfo(channel:String, song:String, artist:String, imageData: UIImage)
    {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        let image = imageData.withBackground(color: UIColor(displayP3Red: 19 / 255, green: 20 / 255, blue: 36 / 255, alpha: 1.0))
        let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: {  (_) -> UIImage in
            return image
        })
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = song
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = channel
        nowPlayingInfo[MPMediaItemPropertyPodcastTitle] = song
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        nowPlayingInfo[MPMediaItemPropertyMediaType] = 1
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
        nowPlayingInfo[MPMediaItemPropertyAlbumArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = g.currentChannelName
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
        
        if self.player.rate == 1 {
            nowPlayingInfoCenter.playbackState = .playing
        } else {
            nowPlayingInfoCenter.playbackState = .paused
        }
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        
    }
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        //let size = image.size
        let rect = CGRect(x: 0, y: 0, width: 80, height: 80)
        
        UIGraphicsBeginImageContextWithOptions( targetSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    func autoLaunchServer(completionHandler: CompletionHandler )   {
        print("Restarting Server...")
        
        if UIAccessibility.isVoiceOverRunning {
            let utterance = AVSpeechUtterance(string: "Buffering")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.5
            
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }
        
        do {
            //Find the first Open port
            for i in self.port...64999 {
                let (isFree, _) = Network.ability.checkTcpPortForListen(port: UInt16(i))
                if isFree {
                    self.port = UInt16(i)
                    break
                }
            }
            
            let g = Global.obj
            
            let server = HTTPServer.Server(name: g.localhost, address: g.local, port: Int(self.port), routes: routes() )
            try HTTPServer.launch(wait: false, server)
            
            completionHandler(true)
        } catch {
            completionHandler(false)
            print(error)
        }
    }
    
    func magicTapped() {
        new()
    }
    
    let avSession = AVAudioSession.sharedInstance()
    
    ///These are used on the iPhone's lock screen
    ///Command Center routines
    func setupRemoteTransportControls(application: UIApplication) {
        do {
            avSession.accessibilityPerformMagicTap()
            avSession.accessibilityActivate()
            try avSession.setPreferredIOBufferDuration(0)
            try avSession.setCategory(.playback, mode: .default, policy: .longFormAudio, options: [])
            try avSession.setActive(true)
            
        } catch {
            print(error)
        }
        
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.accessibilityActivate()
        
        commandCenter.playCommand.addTarget(handler: { (event) in
            self.new()
            return MPRemoteCommandHandlerStatus.success}
        )
        
        commandCenter.pauseCommand.addTarget(handler: { (event) in
            self.new()
            return MPRemoteCommandHandlerStatus.success}
        )
        
        commandCenter.togglePlayPauseCommand.addTarget(handler: { (event) in
            self.new()
            return MPRemoteCommandHandlerStatus.success}
        )
    }
}




