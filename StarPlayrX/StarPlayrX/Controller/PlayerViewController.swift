
//
//  Player.swift
//  StarPlayrXi
//
//  Created by Todd on 2/9/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//


import UIKit
import MediaPlayer
import AVKit

var setPlayerObservers = false

//UIGestureRecognizerDelegate
class PlayerViewController: UIViewController, AVRoutePickerViewDelegate  {
    var PlayerTimer : Timer? 	=  nil
    var playerViewTimerX     	=  Timer()
    var playerLock 				= false
    var allStarButton 			= UIButton(type: UIButton.ButtonType.custom)
    var preVolume 				= Float(-1.0)
    
    var sliderIsMoving = false
    var channels = "Channels"
    var rounder = Float(10000.0)
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .bottom }
    override var prefersHomeIndicatorAutoHidden : Bool { return true }
    override var prefersStatusBarHidden: Bool { return false }
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    @IBOutlet weak var routerView: UIView!
    
    //Art Queue
    public let ArtQueue = DispatchQueue(label: "ArtQueue", qos: .background )
    
    //Notifications
    var localChannelArt = ""
    var localAlbumArt = ""
    var preArtistSong = ""
    var setAlbumArt = false
    var maxAlbumAttempts = 3
    
    //constraint outlets
    @IBOutlet weak var ArtistSongViewTop: NSLayoutConstraint!
    @IBOutlet weak var AlbumArtTop: NSLayoutConstraint!
    @IBOutlet weak var SongLabelTop: NSLayoutConstraint!
    @IBOutlet weak var SongLabelBottom: NSLayoutConstraint!
    @IBOutlet weak var AlbumArtCenterX: NSLayoutConstraint!
    
    //end constraints
    @IBOutlet weak var PlayButtonImage: UIButton!
    @IBOutlet weak var albumArt: UIImageView!
    @IBOutlet weak var ArtistLabel: UILabel!
    @IBOutlet weak var SongLabel: UILabel!
    
    
    func PlayPause() {
        if Player.shared.player.isBusy && Player.shared.state == PlayerState.playing {
            updatePlayPauseIcon(play: false)
            Player.shared.pause()
            Player.shared.state = .paused
        } else {
            updatePlayPauseIcon(play: true)
            Player.shared.state = .stream
            Player.shared.player.pause()
            Player.shared.playX()
        }
    }
    @IBAction func PlayButton(_ sender: Any) {
        PlayPause()
    }
    

    func startup() {
        startupVolume()
        PulsarAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AP2VolumeSlider.setValue(AP2Volume.shared()?.getVolume() ?? 0.25, animated: false)
        title = currentChannelName
        syncArt()
        startup()
        checkForAllStar()
        setObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        freshChannels = true
        
        invalidateTimer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.shutdownVolume()
        }
        
        removeObservers()
    }
    
    func setupAirPlayButton() {
        let buttonFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        let airplayButton = AVRoutePickerView(frame: buttonFrame)
        
        airplayButton.prioritizesVideoDevices = false
        airplayButton.delegate = self
        airplayButton.activeTintColor = UIColor.systemBlue
        airplayButton.tintColor = .systemBlue
        routerView.addSubview(airplayButton)
    }
    
    
    func setVolumeObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(gotVolumeDidChange), name: .gotVolumeDidChange, object: nil)
    }
  
    
    func removeVolumeObserver() {
        NotificationCenter.default.removeObserver(self, name: .gotVolumeDidChange, object: nil)
    }
    
    
    //set tab item
    func tabItem(index: Int, enable: Bool, selectItem: Bool) {
        let tabBarArray = self.tabBarController?.tabBar.items
        
        if let tabBarItems = tabBarArray, tabBarItems.count > 0 {
            let tabBarItem = tabBarItems[index]
            tabBarItem.isEnabled = enable
        }
        
        if selectItem {
            self.tabBarController!.selectedIndex = index
        }
    }
    
    //update
    func updatePlayPauseIcon(play: Bool) {
        
        //we know it's playing
        if Player.shared.player.rate > 0 || play {
            
            if let pbi = PlayButtonImage  {
                pbi.setImage(UIImage(named: "pause_button"), for: .normal)
            }
            
        } else {
            
            if let pbi = PlayButtonImage  {
                pbi.setImage(UIImage(named: "play_button"), for: .normal)
            }
        }
    }
    
    
    @objc func doubleTapped() {
        PlayPause()
    }
    
    
    func startupVolume() {
        AP2Volume.shared().hud(false) //Disable HUD on this view
        systemVolumeUpdater()
    }
    
    
    func shutdownVolume() {
        AP2Volume.shared().hud(true) //Enable HUD on this view
    }
    
    
    @objc func willEnterForeground() {
        startup()
        syncArt()
    }
    

    @objc func TB() {
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
    
    
    @objc func UpdatePlayerView() {
        
        if let i = channelArray.firstIndex(where: {$0.channel == currentChannel}) {
            let item = channelArray[i].largeChannelArtUrl
            Player.shared.updateDisplay(key: currentChannel, cache: Player.shared.pdtCache, channelArt: item)
        }
        
    }
    
    
    func PlayerPDT() {
        if PlayerTimer == nil {
            PlayerTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(UpdatePlayerView), userInfo: nil, repeats: true)
        }
    }
    
    func syncArt() {
        
        Player.shared.previousMD5 = Player.shared.MD5(String(CACurrentMediaTime().description))!

        ArtQueue.async {
            if Player.shared.player.isReady {
                if let i = channelArray.firstIndex(where: {$0.channel == currentChannel}) {
                    let item = channelArray[i].largeChannelArtUrl
                    Player.shared.updateDisplay(key: currentChannel, cache: Player.shared.pdtCache, channelArt: item)
                }
            }
        }
    }
    
    
    //View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeObservers()

        addSlider()
        
        setupAirPlayButton()
        
        PlayerPDT()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        if let appearance = navigationController?.navigationBar.standardAppearance {
            appearance.shadowImage = nil
            appearance.shadowColor = UIColor(displayP3Red: 20 / 255, green: 22 / 255, blue: 24 / 255, alpha: 1.0)
            appearance.backgroundColor = UIColor(displayP3Red: 20 / 255, green: 22 / 255, blue: 24 / 255, alpha: 1.0)
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.layer.borderWidth = 0.0
        }
        
        
        allStarButton.setImage(UIImage(named: "star_on"), for: .normal)
        allStarButton.accessibilityLabel = "All Stars Preset"
        allStarButton.addTarget(self, action:#selector(TB), for: .touchUpInside)
        allStarButton.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        let barButton = UIBarButtonItem(customView: allStarButton)
        
        self.navigationItem.rightBarButtonItem = barButton
        self.navigationItem.rightBarButtonItem?.tintColor = .systemBlue
        //let logoutBarButtonItem = UIBarButtonItem(title: "Star", style: .done, target: self, action: #selector(TB))
        //self.navigationItem.rightBarButtonItem  = logoutBarButtonItem
        
        let deviceType = UIDevice().type
        var multiplier = CGFloat()
        var zoomed = false
        
        DispatchQueue.main.async {
            if deviceType == .iPhoneX {
                multiplier = CGFloat(0.999999) // just under 1 works
                self.ArtistSongViewTop.constant = 15 // add some space to the top
                self.SongLabelTop.constant = 0
                self.AlbumArtTop.constant = 15
                
            } else if deviceType == .iPhoneXSMax {
                multiplier = CGFloat(0.999999) // just under 1 works
                self.ArtistSongViewTop.constant = 20 // add even more space to the top
                self.SongLabelTop.constant = 5
                self.AlbumArtTop.constant = 15
                
            } else if deviceType == .iPhone8Plus {
                multiplier = CGFloat(0.999999) // just under 1 works
                self.ArtistSongViewTop.constant = 0 // add even more space to the top
                self.AlbumArtTop.constant = 0
                self.SongLabelTop.constant = 0
                self.SongLabelBottom.constant = 0
                
            } else if deviceType == .iPhone8 && !zoomed || deviceType == .iPhone8Plus && zoomed {
                multiplier = CGFloat(0.9)
            } else if deviceType == .iPhoneSE || deviceType == .iPhone8 && zoomed  {
                multiplier = CGFloat(0.75)
            } else if deviceType == .iPad {
                multiplier = CGFloat(0.7) // just under 1 works
                self.ArtistSongViewTop.constant = 0 // add some space to the top
                self.AlbumArtCenterX.constant = -30
                self.SongLabelTop.constant = 0
                self.AlbumArtTop.constant = 0
                self.SongLabelBottom.constant = 0
            }
            
            if multiplier != 0 {
                self.albumArt?.translatesAutoresizingMaskIntoConstraints = false
                self.albumArt?.addConstraint(NSLayoutConstraint(
                    item: self.albumArt as Any, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal,
                    toItem: self.albumArt, attribute: NSLayoutConstraint.Attribute.width, multiplier: multiplier, constant: 0))
            }
            
            //iPhone 8 Plus and zoomed
            if (UIScreen.main.bounds.size.height == 667.0 && UIScreen.main.nativeScale > UIScreen.main.scale){
                zoomed = true
                //iPhone 8 and zoomed
            } else if (UIScreen.main.bounds.size.height == 568.0 && UIScreen.main.nativeScale > UIScreen.main.scale) {
                zoomed = true
            }
            
            self.navigationController?.navigationBar.shadowImage = UIImage()
            
        }
        
        ArtistLabel.text = ""
        SongLabel.text = ""
    
        //Pause Gesture
        let doubleFingerTapToPause = UITapGestureRecognizer(target: self, action: #selector(PlayerViewController.doubleTapped) )
        doubleFingerTapToPause.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleFingerTapToPause)
        setAlbumArt = false
        
        AP2VolumeSlider.setThumbImage(UIImage(named: "knob")!, for: .normal)
        AP2VolumeSlider.setThumbImage(UIImage(named: "knob")!, for: .highlighted)
        
        setVolumeObserver()
    }
    
    @objc func OnDidUpdatePlay(){
        DispatchQueue.main.async {
            if let pbi = self.PlayButtonImage  {
                pbi.setImage(UIImage(named: "pause_button"), for: .normal)
            }
        }
    }
    
    
    @objc func OnDidUpdatePause(){
        
        DispatchQueue.main.async {
            if let pbi = self.PlayButtonImage  {
                pbi.setImage(UIImage(named: "play_button"), for: .normal)
            }
        }
    }
    
    
    override func accessibilityPerformMagicTap() -> Bool {
        PlayPause()
        
        return true
    }
    
    
    func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(OnDidUpdatePlay), name: .didUpdatePlay, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OnDidUpdatePause), name: .didUpdatePause, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GotNowPlayingInfo), name: .gotNowPlayingInfo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .willEnterForegroundNotification, object: nil)
    }
    
    
    
    func invalidateTimer() {
        self.playerViewTimerX.invalidate()
    }
    
    func airplayRunner() {
        if tabBarController?.tabBar.selectedItem?.title == channels && title == currentChannelName {
            if Player.shared.avSession.currentRoute.outputs.first?.portType == .airPlay {
                AP2Volume.shared().setVolumeBy(0.0)
            } else {
                if let vol = AP2Volume.shared()?.getVolume() {
                    DispatchQueue.main.async {
                        self.AP2VolumeSlider.setValue(vol, animated: true)
                    }
                }
            }
            
            isSliderEnabled()
        }
    }
    
    @objc func systemVolumeUpdater() {
        switch UIApplication.shared.applicationState {
            
            case .active:
                () //airplayRunner()
            case .background:
                () //airplayRunner()
            default:
                ()
        }
    }
    
    
    func startVolumeTimer() {
        invalidateTimer()
        self.playerViewTimerX = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(systemVolumeUpdater), userInfo: nil, repeats: true)
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
    
    @IBOutlet weak var AP2VolumeSlider: UISlider!
    
    //MARK: Pump up the Volume
    @objc func AP2VolumeChanged(slider: UISlider, event: UIEvent) {
        
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
                case .began:
                    sliderIsMoving = true
                    removeVolumeObserver()
                case .moved:
                    DispatchQueue.main.async {
                        AP2Volume.shared().setVolume(slider.value)
                }
                case .ended:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.setVolumeObserver()
                        self.sliderIsMoving = false
                }
                default:
                    return
            }
        }
    }
    
    func addSlider() {
        AP2VolumeSlider.addTarget(self, action: #selector(AP2VolumeChanged(slider:event:)), for: .valueChanged)
    }
    
    func removeSlider() {
        AP2VolumeSlider.removeTarget(nil, action: nil, for: .valueChanged)
    }
    let x = MPMusicPlayerController.applicationMusicPlayer
    
    
    @objc func gotVolumeDidChange(_ notification: NSNotification) {
        if sliderIsMoving { return }
        if let volume = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
            
            if Player.shared.avSession.currentRoute.outputs.first?.portType == .airPlay {
                let vol = AP2Volume.shared()?.getVolume()
                if vol == volume {
                    return
                }
            }
            
            let slider = AP2VolumeSlider.value
            
            let roundedSlider = round(rounder * slider) / rounder
            let roundedVolume = round(rounder * volume) / rounder
            if roundedSlider != roundedVolume {
                
                DispatchQueue.main.async {
                    self.AP2VolumeSlider.setValue(volume, animated: true)
                }
            }
            
        } else {
            //This creates a one time loop back if volume comes back nil
            systemVolumeUpdater()
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
        
        self.routerView.layer.add(pulseAnimation, forKey: nil)
    }
    
    func noPulsar() {
        self.routerView.layer.removeAllAnimations()
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
        
        isSliderEnabled()
        
    }
    
    func isSliderEnabled() {
        if Player.shared.avSession.currentRoute.outputs.first?.portType == .usbAudio  {
            AP2VolumeSlider.isEnabled = false
        } else {
            AP2VolumeSlider.isEnabled = true
            
        }
    }
    
    
    @objc func GotNowPlayingInfo(){
        ArtistLabel.accessibilityLabel = nowPlaying.artist + ". " + nowPlaying.song + "."
        ArtistLabel.isHighlighted = true
        albumArt.accessibilityLabel = "Album Art, " + nowPlaying.artist + ". " + nowPlaying.song + "."
        ArtQueue.async {
            DispatchQueue.main.async {
                UILabel.transition(with: self.ArtistLabel,
                                   duration:0.4,
                                   options: .transitionCrossDissolve,
                                   animations: { self.ArtistLabel.text = nowPlaying.artist },
                                   completion: nil)
                
                UILabel.transition(with: self.SongLabel,
                                   duration:0.4,
                                   options: .transitionCrossDissolve,
                                   animations: { self.SongLabel.text = nowPlaying.song },
                                   completion: nil)
                
                UIView.transition(with: self.albumArt,
                                  duration:0.4,
                                  options: .transitionCrossDissolve,
                                  animations: { self.albumArt.image = nowPlaying.image },
                                  completion: nil)
                
            }
        }
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .didUpdatePlay, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didUpdatePause, object: nil)
        NotificationCenter.default.removeObserver(self, name: .gotNowPlayingInfo, object: nil)
        NotificationCenter.default.removeObserver(self, name: .willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .gotVolumeDidChange, object: nil)
    }
}


/*
 
 let audioSession = AVAudioSession()
 try? audioSession.setActive(true)
 audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
 
 
 */
