
//
//  Player.swift
//  StarPlayrXi
//
//  Created by Todd on 2/9/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//


import UIKit
import AVKit


//UIGestureRecognizerDelegate
class PlayerViewController: UIViewController, AVRoutePickerViewDelegate  {
	
    @IBOutlet weak var mainView: UIView!
    
    //UI Variables
    var PlayerView =  UIView()
    
    
    var Artist          = UILabel()
    var Song            = UILabel()
    var ArtistSong      = UILabel()
    
    var VolumeSlider    = UISlider()
    var AirPlay         = AVRoutePickerView()
    
    var PlayerX         = UIButton()
    var allStarButton   = UIButton(type: UIButton.ButtonType.custom)
    var AlbumArt        = UIImageView()
    
    //Art Queue
    public let ArtQueue = DispatchQueue(label: "ArtQueue", qos: .background )
    

    //MARK: draw Player View
    func drawPlayerView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, iPad: Bool) -> UIView {
        let drawView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        drawView.backgroundColor = UIColor(displayP3Red: 35 / 255, green: 37 / 255, blue: 39 / 255, alpha: 1.0)

        if !iPad {
            drawView.center = CGPoint(x: x, y: y)
        }
       
        self.mainView.addSubview(drawView)
        
        return drawView
    }
   
    
    //MARK: draw Album Art View
    func drawAlbumView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, wire: Bool) -> UIImageView {
        let drawView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        drawView.center = CGPoint(x: x, y: y)
        
        if wire {
            drawView.backgroundColor = .orange
        }
        
        self.PlayerView.addSubview(drawView)
        
        return drawView
    }

    
    //MARK: draw labels
    func drawLabels(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat,
                       align: NSTextAlignment, color: UIColor, text: String = "",
                       font: UIFont, wire: Bool) -> UILabel {
        
        let drawView = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        drawView.center = CGPoint(x: x, y: y)
        
        if wire {
            drawView.textColor = color
        }
        
        drawView.textAlignment = align
        
        drawView.text = text
        drawView.font = font
        drawView.numberOfLines = 2
        
        self.PlayerView.addSubview(drawView)
        
        return drawView
    }

    
    //MARK: Draw VolumeSlider
    func drawVolumeSlider(centerX: CGFloat, centerY: CGFloat, rectX: CGFloat, rectY: CGFloat, width: CGFloat, height: CGFloat) -> UISlider {
        
        let slider = UISlider(frame:CGRect(x: rectX, y: rectY, width: width, height: height))
        slider.center = CGPoint(x: centerX, y: centerY)
        
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = true
        slider.tintColor = .systemBlue
        
        slider.setThumbImage(UIImage(named: "knob"), for: .normal)
        slider.setThumbImage(UIImage(named: "knob"), for: .highlighted)
        
        //mySlider.addTarget(self, action: #selector(ViewController.sliderValueDidChange(_:)), for: .valueChanged)
        
        self.PlayerView.addSubview(slider)
        return slider
    }
    
    
    //MARK: Draw Buttons
    func drawButtons(centerX: CGFloat, centerY: CGFloat, rectX: CGFloat, rectY: CGFloat, width: CGFloat, height: CGFloat, wire: Bool) -> UIButton {
        
        let button = UIButton(frame:CGRect(x: rectX, y: rectY, width: width, height: height))
        button.center = CGPoint(x: centerX, y: centerY)
        
        if wire { button.backgroundColor = .systemBlue }
        
        //mySlider.addTarget(self, action: #selector(ViewController.sliderValueDidChange(_:)), for: .valueChanged)
        
        self.PlayerView.addSubview(button)
        return button
    }
    
    
    //MARK: Draw Buttons
    func drawAirPlay(centerX: CGFloat, centerY: CGFloat, rectX: CGFloat, rectY: CGFloat, width: CGFloat, height: CGFloat, wire: Bool) -> AVRoutePickerView {
        
        let airplayButton = AVRoutePickerView(frame:CGRect(x: rectX, y: rectY, width: width, height: height))
        airplayButton.center = CGPoint(x: centerX, y: centerY)
        
        if wire { airplayButton.backgroundColor = .systemBlue }
        
        airplayButton.prioritizesVideoDevices = false
        airplayButton.delegate = self
        airplayButton.activeTintColor = UIColor.systemBlue
        airplayButton.tintColor = .systemBlue
        
        self.PlayerView.addSubview(airplayButton)
        return airplayButton
    }
    
    
    override func loadView() {
        super.loadView()
        
        let iPhoneHeight = self.mainView.frame.height
        let iPhoneWidth = self.mainView.frame.width
        
        print("iPhoneHeight: ",iPhoneHeight, "iPhoneWidth: ",iPhoneWidth)
        //MARK: Here is we are checking if the user as an iPhone X (it has 18 more pixels in height / Status bar)
        let isIphoneX = (iPhoneHeight == 896.0 || iPhoneHeight == 812.0) ? CGFloat(18) : CGFloat(0)
        
        let frameY = iPhoneHeight - isIphoneX
        
        var iPad = false
        //MARK: Draws out main Player View object : visible "Safe Area" only - calculated
        if let navY = self.navigationController?.navigationBar.frame.size.height,
            let tabY = self.tabBarController?.tabBar.frame.size.height {
            	let y = frameY - navY - tabY
                print("1")
            PlayerView = drawPlayerView(x: self.view.frame.size.width / 2, y: (frameY) / 2, width: self.view.frame.size.width, height: y, iPad: false)
        } else {
            print("2")
			iPad = true
            PlayerView = drawPlayerView(x: 0, y: 0, width: iPhoneWidth - navBarWidth, height: iPhoneHeight - tabBarHeight, iPad: true)

        }
        
        //MARK: Offset Values
        let iPhoneOffset = CGFloat(13) //kicks up some graphics
        
        //MARK: CUSTOMIZATIONS
        let labelOffset: CGFloat
        let labelHeight: CGFloat
        let fontSize: CGFloat
        let iPadAlbumClearSpace: CGFloat
        let AlbumArtSizeX: CGFloat
        let AlbumArtSizeY: CGFloat
        let centerX: CGFloat
        let centerY: CGFloat
        let iPadTabHeightFactor: CGFloat
        //MARK: TO DO - iPad Sizes
        switch iPhoneHeight {
            
            //iPhone 11 Pro Max
            case 896.0 :
                labelOffset = 133
                labelHeight = 90
                fontSize = 18
                iPadAlbumClearSpace = 0
                AlbumArtSizeX = PlayerView.frame.size.width
                AlbumArtSizeY = PlayerView.frame.size.height
                centerX = PlayerView.frame.size.width / 2
                centerY = PlayerView.frame.size.height / 2 - iPhoneOffset
            	iPadTabHeightFactor = 0
            //iPhone 11 Pro / iPhone X
            case 812.0 :
                labelOffset = 110
                labelHeight = 90
                fontSize = 18
                iPadAlbumClearSpace = 0
                AlbumArtSizeX = PlayerView.frame.size.width
                AlbumArtSizeY = PlayerView.frame.size.height
                centerX = PlayerView.frame.size.width / 2
                centerY = PlayerView.frame.size.height / 2 - iPhoneOffset
                iPadTabHeightFactor = 0

            //iPhone 8 Plus
            case 736.0 :
                labelOffset = 86
                labelHeight = 60
                fontSize = 18
                iPadAlbumClearSpace = 0
                AlbumArtSizeX = PlayerView.frame.size.width
                AlbumArtSizeY = PlayerView.frame.size.height
                centerX = PlayerView.frame.size.width / 2
                centerY = PlayerView.frame.size.height / 2 - iPhoneOffset
                iPadTabHeightFactor = 0

            //iPhone 7/8/SE 2nd Gen
            case 667.0 :
                labelOffset = 70
                labelHeight = 60
                fontSize = 17
                iPadAlbumClearSpace = 0
                AlbumArtSizeX = PlayerView.frame.size.width
                AlbumArtSizeY = PlayerView.frame.size.height
                centerX = PlayerView.frame.size.width / 2
                centerY = PlayerView.frame.size.height / 2 - iPhoneOffset
                iPadTabHeightFactor = 0

            //iPhone SE 1st Gen
            case 568.0 :
                labelOffset = 48
                labelHeight = 60
                fontSize = 16
                iPadAlbumClearSpace = 0
                AlbumArtSizeX = PlayerView.frame.size.width
                AlbumArtSizeY = PlayerView.frame.size.height
                centerX = PlayerView.frame.size.width / 2
                centerY = PlayerView.frame.size.height / 2 - iPhoneOffset
                iPadTabHeightFactor = 0

            //iPad Pro 12.9"
            case 1024.0 :
                labelOffset = 48
                labelHeight = 60
                fontSize = 18
                iPadAlbumClearSpace = 200
                AlbumArtSizeX = PlayerView.frame.size.width - iPadAlbumClearSpace
                AlbumArtSizeY = PlayerView.frame.size.height - iPadAlbumClearSpace
                centerX = PlayerView.frame.size.width / 2
                centerY = (PlayerView.frame.size.height - tabBarHeight) / 2
                iPadTabHeightFactor = 1.9

            //iPad 11"
            case 834.0 :
                labelOffset = 0
                labelHeight = 60
                fontSize = 17
                iPadAlbumClearSpace = 185
                AlbumArtSizeX = PlayerView.frame.size.width - iPadAlbumClearSpace
                AlbumArtSizeY = PlayerView.frame.size.height - iPadAlbumClearSpace
                centerX = PlayerView.frame.size.width / 2
                centerY = (PlayerView.frame.size.height - tabBarHeight) / 2
                iPadTabHeightFactor = 2.2
            
            //iPad 9"
            case 810.0 :
                labelOffset = 0
                labelHeight = 30
                fontSize = 16
                iPadAlbumClearSpace = 150
                AlbumArtSizeX = PlayerView.frame.size.width - iPadAlbumClearSpace
                AlbumArtSizeY = PlayerView.frame.size.height - iPadAlbumClearSpace
                centerX = PlayerView.frame.size.width / 2
                centerY = (PlayerView.frame.size.height - tabBarHeight) / 2
                iPadTabHeightFactor = 1.7
            

            //iPad 9"
            case 768.0 :
                labelOffset = 0
                labelHeight = 30
                fontSize = 16
                iPadAlbumClearSpace = 140
                AlbumArtSizeX = PlayerView.frame.size.width - iPadAlbumClearSpace
                AlbumArtSizeY = PlayerView.frame.size.height - iPadAlbumClearSpace
                centerX = PlayerView.frame.size.width / 2
                centerY = (PlayerView.frame.size.height - tabBarHeight) / 2
                iPadTabHeightFactor = 1.425

            default :
                labelOffset = 48
                labelHeight = 60
                fontSize = 16
                iPadAlbumClearSpace = 0
                AlbumArtSizeX = PlayerView.frame.size.width
                AlbumArtSizeY = PlayerView.frame.size.height
                centerX = PlayerView.frame.size.width / 2
                centerY = PlayerView.frame.size.height / 2 - iPhoneOffset
                iPadTabHeightFactor = 0
        }
        
        AlbumArt = drawAlbumView(x: centerX, y: centerY, width: AlbumArtSizeX, height: AlbumArtSizeX, wire: false)
        AlbumArt.layer.shadowColor = UIColor(displayP3Red: 35 / 2 / 255, green: 37 / 2 / 255, blue: 39 / 2 / 255, alpha: 1.0).cgColor
        AlbumArt.layer.shadowOpacity = 1.0
        AlbumArt.layer.shadowOffset = .zero
        AlbumArt.layer.shadowRadius = fontSize * 2
        AlbumArt.layer.shadowPath = UIBezierPath(rect: AlbumArt.bounds).cgPath
        AlbumArt.alpha = 0.0
            
        //MARK: Draw Artist Label
        
        if !iPad {
            Artist = drawLabels(x: centerX, y: (AlbumArtSizeY - AlbumArtSizeX - labelOffset) / 2 - iPhoneOffset, width: AlbumArtSizeX, height: labelHeight, align: .center, color: .white, text: "", font: .systemFont(ofSize: fontSize, weight: UIFont.Weight.semibold), wire: true)
            
            Song = drawLabels(x: centerX, y: (PlayerView.frame.size.height + PlayerView.frame.size.width + labelOffset) / 2 - iPhoneOffset, width: AlbumArtSizeX, height: labelHeight, align: .center, color: .white, text: "", font: .systemFont(ofSize: fontSize, weight: UIFont.Weight.medium), wire: true)
        } else {
            
            ArtistSong = drawLabels(x: centerX, y: AlbumArtSizeY + (tabBarHeight * iPadTabHeightFactor), width: AlbumArtSizeX, height: labelHeight, align: .center, color: .white, text: "", font: .systemFont(ofSize: fontSize, weight: UIFont.Weight.semibold), wire: true)
        }
    
        //defines the variables we are using. Might tweak this add and some constants
        let sliderWidth = CGFloat( PlayerView.frame.size.width - 120 )
        let positionBottom = CGFloat( PlayerView.frame.size.height - 30 )
        let buttonOffset = CGFloat(30)
    	let buttonSize = CGFloat(28)
        let airplaySize = CGFloat(52)

        VolumeSlider = drawVolumeSlider(centerX: centerX, centerY: positionBottom, rectX: 0, rectY: 0, width: sliderWidth, height: labelHeight)
        PlayerX = drawButtons(centerX: buttonOffset, centerY: positionBottom, rectX: 0, rectY: 0, width: buttonSize, height: buttonSize, wire: false)
        updatePlayPauseIcon(play: true)
    
        AirPlay = drawAirPlay(centerX: PlayerView.frame.size.width - buttonOffset, centerY: positionBottom, rectX: 0, rectY: 0, width: airplaySize, height: airplaySize, wire: false)
        
        setAllStarButton()
        
    }

    
    func setObservers() {
        //NotificationCenter.default.addObserver(self, selector: #selector(OnDidUpdatePlay), name: .didUpdatePlay, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(OnDidUpdatePause), name: .didUpdatePause, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GotNowPlayingInfo), name: .gotNowPlayingInfo, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .willEnterForegroundNotification, object: nil)
    }
    //update
    func updatePlayPauseIcon(play: Bool) {
        
        //we know it's playing
        if Player.shared.player.rate > 0 || play {
            self.PlayerX.setImage(UIImage(named: "pause_button"), for: .normal)
        } else {
            self.PlayerX.setImage(UIImage(named: "play_button"), for: .normal)
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
    
    final override func viewDidLoad() {
        super.viewDidLoad()

		print("VIEW DID LOAD.")
       	setObservers()
    }
    
    @objc func GotNowPlayingInfo(){
        Artist.accessibilityLabel = nowPlaying.artist + ". " + nowPlaying.song + "."
        ArtistSong.accessibilityLabel = nowPlaying.artist + ". " + nowPlaying.song + "."

        Artist.isHighlighted = true
        AlbumArt.accessibilityLabel = "Album Art, " + nowPlaying.artist + ". " + nowPlaying.song + "."
        
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
    }
    
    
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .bottom }
    override var prefersHomeIndicatorAutoHidden : Bool { return true }
    
    override func viewWillAppear(_ animated: Bool) {
        //AP2VolumeSlider.setValue(AP2Volume.shared()?.getVolume() ?? 0.25, animated: false)
        title = currentChannelName
        
 
        syncArt()
        //startup()
        //checkForAllStar()
        //setObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        freshChannels = true
        
        //invalidateTimer()
        
        
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //    self.shutdownVolume()
        //}
        
        //removeObservers()
    }
    
    
    func syncArt() {
        
     
            
        if let md5 = Player.shared.MD5(String(CACurrentMediaTime().description)) {
        	Player.shared.previousMD5 = md5
        } else {
            let str = "Hello, Last Star Player X."
            Player.shared.previousMD5 = Player.shared.MD5(String(str)) ?? str
        }
         
        ArtQueue.async {
            if Player.shared.player.isReady {
                if let i = channelArray.firstIndex(where: {$0.channel == currentChannel}) {
                    let item = channelArray[i].largeChannelArtUrl
                    Player.shared.updateDisplay(key: currentChannel, cache: Player.shared.pdtCache, channelArt: item)
                }
            }
        }
    }
    

}
    /*var PlayerTimer : Timer? 	=  nil
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
    
   
    //Notifications
    var localChannelArt = ""
    var localAlbumArt = ""
    var preArtistSong = ""
    var setAlbumArt = false
    var maxAlbumAttempts = 3
    
   
    
    @IBOutlet weak var PlayButtonImage: UIButton!
    @IBOutlet weak var albumArt: UIImageView!
    @IBOutlet weak var ArtistLabel: UILabel!
    @IBOutlet weak var SongLabel: UILabel!
    
    
    func PlayPause() {
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
    
    @IBAction func PlayButton(_ sender: Any) {
        PlayPause()
    }
    

    func startup() {
        startupVolume()
        PulsarAnimation()
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
                airplayRunner()
            case .background:
              	airplayRunner()
            default:
                ()
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

*/
/*
 
 let audioSession = AVAudioSession()
 try? audioSession.setActive(true)
 audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
 
 
 */
