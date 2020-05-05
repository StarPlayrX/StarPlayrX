
//
//  Player.swift
//  StarPlayrX
//
//  Created by Todd on 2/9/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//


import UIKit
import AVKit


//UIGestureRecognizerDelegate
class PlayerViewController: UIViewController, AVRoutePickerViewDelegate  {
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .bottom }
    override var prefersHomeIndicatorAutoHidden : Bool { return true }
    
    @IBOutlet weak var mainView: UIView!
    
    //UI Variables
    var PlayerView       = UIView()
    
    var Artist          = UILabel()
    var Song            = UILabel()
    var ArtistSong      = UILabel()
    
    var VolumeSlider    = UISlider()
    
    var AirPlayView     = UIView()
    var AirPlayBtn : AVRoutePickerView = AVRoutePickerView()

    var SpeakerView     = UIImageView()
    
    var PlayerXL        = UIButton()
    var allStarButton   = UIButton(type: UIButton.ButtonType.custom)
    var AlbumArt        = UIImageView()
    
    var currentSpeaker = Speakers.speaker0
    var previousSpeaker = Speakers.speaker3
    
    //other variables
    let rounder = Float(10000.0)
    var sliderIsMoving = false
    var channelString = "Channels"
    var playerViewTimerX =  Timer()
    
    let speakerSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 28)
    
    //Art Queue
    public let ArtQueue = DispatchQueue(label: "ArtQueue", qos: .background )
    
    @objc func TB() {
        let sp = Player.shared
        sp.SPXPresets = [String]()
        
        var index = -1
        for d in channelArray {
            index += 1
            if d.channel == currentChannel {
                channelArray[index].preset = !channelArray[index].preset
                
                if channelArray[index].preset {
                    allStarButton.setImage(UIImage(named: "star_on"), for: .normal)
                    allStarButton.accessibilityLabel = "All Stars Preset On, \(currentChannelName)"
                    
                } else {
                    allStarButton.setImage(UIImage(named: "star_off"), for: .normal)
                    allStarButton.accessibilityLabel = "All Stars Preset Off, \(currentChannelName)"
                    
                }
            }
            
            if channelArray[index].preset {
                sp.SPXPresets.append(d.channel)
            }
        }
        
        if !sp.SPXPresets.isEmpty {
            UserDefaults.standard.set(sp.SPXPresets, forKey: "SPXPresets")
        }
    }
    
    func Pulsar() {
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 2
        pulseAnimation.fromValue = 1
        pulseAnimation.toValue = 0.25
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        
        self.AirPlayView.layer.add(pulseAnimation, forKey: nil)
    }
    
    
    func noPulsar() {
        self.AirPlayView.layer.removeAllAnimations()
    }
    
    func PulsarAnimation(tune: Bool = false) {
        if Player.shared.avSession.currentRoute.outputs.first?.portType == .airPlay {
            Pulsar()
            
            if tune {
                Player.shared.change()
            }
            
        } else {
            noPulsar()
            
            if tune {
                Player.shared.change()
            }
        }
    }
    
    
    
    func startVolumeTimer() {
        invalidateTimer()
        self.playerViewTimerX = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(systemVolumeUpdater), userInfo: nil, repeats: true)
    }
    
    func routePickerViewWillBeginPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        systemVolumeUpdater()
        startVolumeTimer()
        PulsarAnimation()
    }
    
    func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        invalidateTimer()
        systemVolumeUpdater()
        PulsarAnimation()
    }
    
    
    func checkForAllStar() {
        let data = channelArray
        
        for c in data {
            if c.channel == currentChannel {
                
                if c.preset {
                    allStarButton.setImage(UIImage(named: "star_on"), for: .normal)
                } else {
                    allStarButton.setImage(UIImage(named: "star_off"), for: .normal)
                }
                break
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        syncArt()
        
        var iPhone = true
        var NavY = CGFloat(0)
        var TabY = CGFloat(0)
        
        //MARK: Draws out main Player View object : visible "Safe Area" only - calculated
        if let navY = self.navigationController?.navigationBar.frame.size.height,
            let tabY = self.tabBarController?.tabBar.frame.size.height {
            
            NavY = navY
            TabY = tabY
            iPhone = true

        } else if let tabY = self.tabBarController?.tabBar.frame.size.height {
            
            NavY = 0
            TabY = tabY
            iPhone = false
        }
        
        //Instantiate draw class
        let draw = Draw(frame: mainView.frame, isPhone: iPhone, NavY: NavY, TabY: TabY)
        
        //MARK: 1 - PlayerView must run 1st
        PlayerView = draw.PlayerView(mainView: mainView)
        AlbumArt   = draw.AlbumImageView(playerView: PlayerView)
        
        if iPhone {
            let artistSongLabelArray = draw.ArtistSongiPhone(playerView: PlayerView)
            Artist = artistSongLabelArray[0]
            Song   = artistSongLabelArray[1]
        } else {
            ArtistSong = draw.ArtistSongiPad(playerView: PlayerView)
        }
        
        /*
        //MARK: Draw Artist / Song Labels
        
        if iPad {
            //MARK: iPad Combo Artist • Song — Channel Label
            ArtistSong = draw.drawLabels(playerView: PlayerView, x: centerX, y: labelOffset, width: AlbumArtSizeX, height: labelHeight, align: .center, color: .white, text: "", font: .systemFont(ofSize: fontSize, weight: UIFont.Weight.semibold), wire: true)
        } else {
            //MARK: iPhone has separate Artist / Song labels without Channel Label (which is in the nav bar)
  
        }
        
        let sliderWidth = CGFloat( PlayerView.frame.size.width - 120 )
        let positionBottom = CGFloat( PlayerView.frame.size.height - SE )
        let buttonOffset = CGFloat(30)
        let buttonSize = CGFloat(30)
        let airplaySize = CGFloat(52)
        
        VolumeSlider = draw.drawVolumeSlider(playerView: PlayerView, centerX: centerX, centerY: positionBottom, rectX: 0, rectY: 0, width: sliderWidth, height: labelHeight)
        addSlider()
        
        PlayerXL = draw.drawButtons(playerView: PlayerView, centerX: centerX, centerY: positionBottom - playPauseY, rectX: 0, rectY: 0, width: buttonSize * playPauseScale, height: buttonSize * playPauseScale, wire: false)
        
        PlayerXL.addTarget(self, action: #selector(PlayPause), for: .touchUpInside)
        
        SpeakerView = draw.drawImage(playerView: PlayerView, centerX: buttonOffset, centerY: positionBottom, rectX: 0, rectY: 0, width: buttonSize, height: buttonSize, wire: false)
        
        let speakerImage = UIImage(named:"speaker1")
        SpeakerView.image = speakerImage
        
        updatePlayPauseIcon(play: true)
        
        setAllStarButton()
        
        let ap = draw.drawAirPlay(airplayView: AirPlayView, playerView: PlayerView, centerX: self.PlayerView.frame.size.width - buttonOffset, centerY: positionBottom, rectX: 0, rectY: 0, width: airplaySize, height: airplaySize, wire: false)
        
        AirPlayView = ap[0] as! UIView
        AirPlayBtn  = ap[1] as! AVRoutePickerView

        */
    }
    
    func startupVolume() {
        let ap2 = AP2Volume.shared()!
        ap2.hud(false) //Disable HUD on this view
        systemVolumeUpdater()
        setSpeakers(value: ap2.getVolume())
    }
    
    func shutdownVolume() {
        AP2Volume.shared().hud(true) //Enable HUD on this view
    }
    
    @objc func OnDidUpdatePlay(){
        DispatchQueue.main.async {
            self.updatePlayPauseIcon(play: true)
        }
    }
    
    
    @objc func OnDidUpdatePause(){
        DispatchQueue.main.async {
            self.updatePlayPauseIcon(play: false)
        }
    }
    
    //MARK: Start Observers
    func setVolumeObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(gotVolumeDidChange), name: .gotVolumeDidChange, object: nil)
    }
    
    func removeVolumeObserver() {
        NotificationCenter.default.removeObserver(self, name: .gotVolumeDidChange, object: nil)
    }
    
    func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(OnDidUpdatePlay), name: .didUpdatePlay, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OnDidUpdatePause), name: .didUpdatePause, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GotNowPlayingInfoAnimated), name: .gotNowPlayingInfoAnimated, object: nil)
        
            NotificationCenter.default.addObserver(self, selector: #selector(GotNowPlayingInfo), name: .gotNowPlayingInfo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .willEnterForegroundNotification, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .didUpdatePlay, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didUpdatePause, object: nil)
        NotificationCenter.default.removeObserver(self, name: .gotNowPlayingInfoAnimated, object: nil)
        NotificationCenter.default.removeObserver(self, name: .gotNowPlayingInfo, object: nil)

    	NotificationCenter.default.removeObserver(self, name: .willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .gotVolumeDidChange, object: nil)
    }
    //MARK: End Observers
    
    
    //MARK: Update Play Pause Icon
    func updatePlayPauseIcon(play: Bool? = nil) {
        
        switch play {
            case .none :
                
                Player.shared.state == PlayerState.playing ?
                    self.PlayerXL.setImage(UIImage(named: "pause_button"), for: .normal) :
                    self.PlayerXL.setImage(UIImage(named: "play_button"), for:  .normal)
            
            case .some(true) :
                
                self.PlayerXL.setImage(UIImage(named: "pause_button"), for: .normal)
            
            case .some(false) :
                self.PlayerXL.setImage(UIImage(named: "play_button"), for: .normal)
        }
    }
    
    func setAllStarButton() {
        allStarButton.setImage(UIImage(named: "star_on"), for: .normal)
        allStarButton.accessibilityLabel = "All Stars Preset"
        allStarButton.addTarget(self, action:#selector(AllStarX), for: .touchUpInside)
        allStarButton.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        let barButton = UIBarButtonItem(customView: allStarButton)
        
        self.navigationItem.rightBarButtonItem = barButton
        self.navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    
    @objc func AllStarX() {
        let sp = Player.shared
        sp.SPXPresets = [String]()
        
        var index = -1
        for d in channelArray {
            index = index + 1
            if d.channel == currentChannel {
                channelArray[index].preset = !channelArray[index].preset
                
                if channelArray[index].preset {
                    allStarButton.setImage(UIImage(named: "star_on"), for: .normal)
                    allStarButton.accessibilityLabel = "All Stars Preset On, \(currentChannelName)"
                    
                } else {
                    allStarButton.setImage(UIImage(named: "star_off"), for: .normal)
                    allStarButton.accessibilityLabel = "All Stars Preset Off, \(currentChannelName)"
                    
                }
            }
            
            if channelArray[index].preset {
                sp.SPXPresets.append(d.channel)
            }
        }
        
        if !sp.SPXPresets.isEmpty {
            UserDefaults.standard.set(sp.SPXPresets, forKey: "SPXPresets")
        }
    }
    
	//MARK: Magic tap for the rest of us
    @objc func doubleTapped() {
        PlayPause()
    }
    
    func doubleTap() {
        //Pause Gesture
        let doubleFingerTapToPause = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapped) )
        doubleFingerTapToPause.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleFingerTapToPause)
    }
    
    final override func viewDidLoad() {
        super.viewDidLoad()
        setObservers()
        doubleTap()
        AirPlayBtn.delegate = self
    }
    
    @objc func GotNowPlayingInfoAnimated() {
        GotNowPlayingInfo(true)
    }
    
    @objc func GotNowPlayingInfo(_ animated: Bool = true) {
        Artist.accessibilityLabel = nowPlaying.artist + ". " + nowPlaying.song + "."
        ArtistSong.accessibilityLabel = nowPlaying.artist + ". " + nowPlaying.song + "."
        
        Artist.isHighlighted = true
        AlbumArt.accessibilityLabel = "Album Art, " + nowPlaying.artist + ". " + nowPlaying.song + "."
        
        if animated {
            DispatchQueue.main.async {
                UILabel.transition(with: self.ArtistSong,
                                   duration:0.4,
                                   options: .transitionCrossDissolve,
                                   animations: { self.ArtistSong.text = nowPlaying.artist + " • " + nowPlaying.song + " — " + currentChannelName  },
                                   completion: nil)
                
                UILabel.transition(with: self.Artist,
                                   duration:0.4,
                                   options: .transitionCrossDissolve,
                                   animations: { self.Artist.text = nowPlaying.artist },
                                   completion: nil)
                
                UILabel.transition(with: self.Song,
                                   duration:0.4,
                                   options: .transitionCrossDissolve,
                                   animations: { self.Song.text = nowPlaying.song },
                                   completion: nil)
                
                UIView.transition(with: self.AlbumArt,
                                  duration:0.4,
                                  options: .transitionCrossDissolve,
                                  animations: { _ = [self.AlbumArt.image = nowPlaying.image, self.AlbumArt.alpha = 1.0] },
                                  completion: nil)
            }
        } else {
            self.ArtistSong.text = nowPlaying.artist + " • " + nowPlaying.song + " — " + currentChannelName
            self.Artist.text = nowPlaying.artist
            self.Song.text = nowPlaying.song
            self.AlbumArt.image = nowPlaying.image
            self.AlbumArt.alpha = 1.0
        }
    }
    
    @objc func PlayPause() {
        if Player.shared.player.isBusy && Player.shared.state == PlayerState.playing {
            updatePlayPauseIcon(play: false)
            Player.shared.state = .paused
            Player.shared.pause()
        } else {
            updatePlayPauseIcon(play: true)
            Player.shared.state = .stream
            
            DispatchQueue.global().async {
                Player.shared.player.pause()
                Player.shared.playX()
            }
        }
    }
    
    func invalidateTimer() {
        self.playerViewTimerX.invalidate()
    }
    
    
    func startup() {
        startupVolume()
        PulsarAnimation(tune: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        VolumeSlider.setValue(AP2Volume.shared().getVolume(), animated: false)
        title = currentChannelName
        startup()
        checkForAllStar()
        setObservers()
        isSliderEnabled()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        shutdownVolume()
        
        UIView.transition(with: self.AlbumArt,
                          duration:0.4,
                          options: .transitionCrossDissolve,
                          animations: { _ = [self.AlbumArt.alpha = 0.0] },
                          completion: nil)
        
        removeObservers()
    }
    
    //MARK: Update the screen
    func syncArt() {
        
        if let md5 = Player.shared.MD5(String(CACurrentMediaTime().description)) {
            Player.shared.previousMD5 = md5
        } else {
            let str = "Hello, Last Star Player X."
            Player.shared.previousMD5 = Player.shared.MD5(String(str)) ?? str
        }
        
        if Player.shared.player.isReady {
            if let i = channelArray.firstIndex(where: {$0.channel == currentChannel}) {
                let item = channelArray[i].largeChannelArtUrl
                Player.shared.updateDisplay(key: currentChannel, cache: Player.shared.pdtCache, channelArt: item, false)
            }
        }
    }
    
    //MARK: Speaker Volume with Smooth Frame Animation
    func setSpeakers(value: Float) {
        self.previousSpeaker = self.currentSpeaker
        
        switch (value) {
            case 0 :
                self.currentSpeaker = .speaker0
            case 0..<0.1 :
                self.currentSpeaker = .speaker1
            case 0.1..<0.2 :
                self.currentSpeaker = .speaker2
            case 0.2..<0.3 :
                self.currentSpeaker = .speaker3
            case 0.3..<0.4 :
                self.currentSpeaker = .speaker4
            case 0.4..<0.5 :
                self.currentSpeaker = .speaker5
            case 0.5..<0.6 :
                self.currentSpeaker = .speaker6
            case 0.6..<0.7 :
                self.currentSpeaker = .speaker7
            case 0.7..<0.8 :
                self.currentSpeaker = .speaker8
            case 0.8..<0.9 :
                self.currentSpeaker = .speaker9
            case 0.9...1.0 :
                self.currentSpeaker = .speaker10
            
            default :
                self.currentSpeaker = .speaker0
        }
        
        if self.previousSpeaker != self.currentSpeaker {
            let speakerName = self.currentSpeaker.rawValue
            
            UIView.transition(with: self.SpeakerView,
                              duration:0.2,
                              options: .transitionCrossDissolve,
                              animations: { self.SpeakerView.image = UIImage(named: speakerName) },
                              completion: nil)
            
            
            self.previousSpeaker = self.currentSpeaker
        }
    }
    
    
    //MARK: Adjust the volume
    @objc func VolumeChanged(slider: UISlider, event: UIEvent) {
        
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
                case .began:
                    ()
                    removeVolumeObserver()
                
                case .moved:
                    DispatchQueue.main.async {
                        let value = slider.value
                        AP2Volume.shared().setVolume(value)
                        self.setSpeakers(value: value)
                        
                }
                case .ended:
                    ()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.setVolumeObserver()
                }
                default:
                    return
            }
        }
    }
    
    
    //MARK: Add Volume Slider Action
    func addSlider() {
        VolumeSlider.addTarget(self, action: #selector(VolumeChanged(slider:event:)), for: .valueChanged)
    }
    
    
    //MARK: Remove Volume Slider Action
    func removeSlider() {
        VolumeSlider.removeTarget(nil, action: #selector(VolumeChanged(slider:event:)), for: .valueChanged)
    }
    
    
    @objc func gotVolumeDidChange(_ notification: NSNotification) {
        if sliderIsMoving { return }
        if let volume = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
            
            if Player.shared.avSession.currentRoute.outputs.first?.portType == .airPlay {
                let vol = AP2Volume.shared()?.getVolume()
                if vol == volume {
                    return
                }
            }
            
            let slider = VolumeSlider.value
            
            let roundedSlider = round(rounder * slider) / rounder
            let roundedVolume = round(rounder * volume) / rounder
            
            if roundedSlider != roundedVolume {
                
                DispatchQueue.main.async {
                    self.VolumeSlider.setValue(volume, animated: true)
                }
            }
            
        } else {
            //This creates a one time loop back if volume comes back nil
            systemVolumeUpdater()
        }
    }
    
    
    @objc func systemVolumeUpdater() {
        switch UIApplication.shared.applicationState {
            
            case .active:
                airplayRunner()
            case .background:
                airplayRunner()
            default:
                ()
        }
    }
    
    
    func isSliderEnabled() {
        if Player.shared.avSession.currentRoute.outputs.first?.portType == .usbAudio  {
            VolumeSlider.isEnabled = false
        } else {
            VolumeSlider.isEnabled = true
        }
    }
    
    
    func airplayRunner() {
        if tabBarController?.tabBar.selectedItem?.title == channelString && title == currentChannelName {
            if Player.shared.avSession.currentRoute.outputs.first?.portType == .airPlay {
                AP2Volume.shared().setVolumeBy(0.0)
            } else {
                if let vol = AP2Volume.shared()?.getVolume() {
                    DispatchQueue.main.async {
                        self.VolumeSlider.setValue(vol, animated: true)
                    }
                }
            }
            
            isSliderEnabled()
        }
    }
    
    
    override func accessibilityPerformMagicTap() -> Bool {
        PlayPause()
        return true
    }
    
    
    @objc func willEnterForeground() {
        startup()
        syncArt()
    }
    
    
    //set tab item
    /*func tabItem(index: Int, enable: Bool, selectItem: Bool) {
        let tabBarArray = self.tabBarController?.tabBar.items
        
        if let tabBarItems = tabBarArray, tabBarItems.count > 0 {
            let tabBarItem = tabBarItems[index]
            tabBarItem.isEnabled = enable
        }
        
        if selectItem {
            self.tabBarController!.selectedIndex = index
        }
    }*/
    
    
}

//Speakers enum
enum Speakers : String {
    case speaker0 = "speaker0"
    case speaker1 = "speaker1"
    case speaker2 = "speaker2"
    case speaker3 = "speaker3"
    case speaker4 = "speaker4"
    case speaker5 = "speaker5"
    case speaker6 = "speaker6"
    case speaker7 = "speaker7"
    case speaker8 = "speaker8"
    case speaker9 = "speaker9"
    case speaker10 = "speaker10"
}






/*var PlayerTimer : Timer? 	=  nil
 var playerLock 				= false
 var allStarButton 			= UIButton(type: UIButton.ButtonType.custom)
 var preVolume 				= Float(-1.0)
 
 
 override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .bottom }
 override var prefersHomeIndicatorAutoHidden : Bool { return true }
 override var prefersStatusBarHidden: Bool { return false }
 override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
 
 @IBOutlet weak var routerView: UIView!
 
 
 //Notifications
 var localChannelArt = ""
 var localAlbumArt = ""
 var preArtistSong = ""
 var setAlbumArt = false
 var maxAlbumAttempts = 3

 
 

 
 

 
 
 
 
 
 
 
 
 
 
 
 
 @objc func UpdatePlayerView() {
 
 if let i = channelArray.firstIndex(where: {$0.channel == currentChannel}) {
 let item = channelArray[i].largeChannelArtUrl
 Player.shared.updateDisplay(key: currentChannel, cache: Player.shared.pdtCache, channelArt: item)
 }
 
 }
 
 

 
 
 //View Did Load
 override func viewDidLoad() {
 super.viewDidLoad()
 
 removeObservers()
 
 addSlider()
 
 
 
 let deviceType = UIDevice().type
 var multiplier = CGFloat()
 var zoomed = false
 
 
 ArtistLabel.text = ""
 SongLabel.text = ""
 

 
 
 setAlbumArt = false

 
 setVolumeObserver()
 }
 
 

 

 
 
 
 
 
 
 
 


 
 }
 

 
 }
 
 */
/*
 
 let audioSession = AVAudioSession()
 try? audioSession.setActive(true)
 audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
 
 
 */
