
//
//  Player.swift
//  StarPlayrXi
//
//  Created by Todd on 2/9/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//


import UIKit
import MediaPlayer

var playerLock = false;

var playerViewTimer     :   Timer? = nil
var playerPauseButton   :   ()? = nil
var playerPlayButton    :   ()? = nil
var getNowPlayingInfo   :   ()? = nil
var avAudioInterruption :   ()? = nil
var didPlayPause        :   ()? = nil
var didStartPlaying     :   ()? = nil

//UIGestureRecognizerDelegate
class PlayerViewController: UIViewController  {
    
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    @IBOutlet weak var StreamVolume: UISlider!
    
    @IBAction func StreamVolumeAction(_ sender: Any) {
        setStreamVolume()
    }
    
    @IBAction func PlayButton(_ sender: Any) {
         NotificationCenter.default.post(name: .didPlayPause, object: nil)
    }
    
    func setStreamVolume() {
        gSliderVolume = StreamVolume.value
        
        if let starplayr = player {
            
            if let volume = gSliderVolume {
                starplayr.volume = volume
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let volume = gSliderVolume {
            gSliderVolume = StreamVolume.value
            UserDefaults.standard.set(volume, forKey: "StreamVolume")
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        ArtistLabel.text = ""
        SongLabel.text = ""

        var volume = Float(1.0)
        let volKey = UserDefaults.standard.object(forKey: "StreamVolume") != nil
        
        if volKey {
            volume = UserDefaults.standard.float(forKey: "StreamVolume")
        } else {
            volume = Float(1.0)
        }
        
        gSliderVolume = volume
        
        //Set Stream Volume
        if volume >= 0 && volume <= 1.0 {
            StreamVolume.value = volume
        } else {
            StreamVolume.value = Float(1.0)
        }
        
        UserDefaults.standard.set(StreamVolume.value, forKey: "StreamVolume")
      
        
        title = currentChannelName
        
      
        
        playerPauseButton = nil
        playerPlayButton = NotificationCenter.default.addObserver(self, selector: #selector(OnDidUpdatePlay(_:)), name: .didUpdatePlay, object: nil)
        
        playerPauseButton = nil
        playerPauseButton = NotificationCenter.default.addObserver(self, selector: #selector(OnDidUpdatePause(_:)), name: .didUpdatePause, object: nil)
        
        didPlayPause = nil
        didPlayPause = NotificationCenter.default.addObserver(self, selector: #selector(OnDidPlayPause(_:)), name: .didPlayPause, object: nil)
        
        didStartPlaying = nil
        didStartPlaying = NotificationCenter.default.addObserver(self, selector: #selector(OnDidStartPlaying(_:)), name: .didStartPlaying, object: nil)

        getNowPlayingInfo = nil
        getNowPlayingInfo = NotificationCenter.default.addObserver(self, selector: #selector(GotNowPlayingInfo(_:)), name: .gotNowPlayingInfo, object: nil)
        
        avAudioInterruption = nil
        getNowPlayingInfo = NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: .gotSessionInterruption, object: nil)
        
        NotificationCenter.default.post(name: .didStartPlaying, object: nil)


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
    
    func startPlayer() {
        
        gSliderVolume = StreamVolume.value
        
        if let starplayr = player {
            
            if !starplayr.isBusy {
                
                if let volume = gSliderVolume {
                    PlayStream(volume: volume )
                    lastchannel = currentChannel
                }
            }
        }
        
        updatePlayPauseIcon(play:true)
    }
        
    
    //update
    func updatePlayPauseIcon(play: Bool) {
        
        if let starplayr = player {
            //we know it's playing
            if starplayr.isPlaying || play {
                
                if let pbi = PlayButtonImage  {
                    pbi.setImage(UIImage(named: "pause_button"), for: .normal)
                }
                
            } else {
                
                if let pbi = PlayButtonImage  {
                    pbi.setImage(UIImage(named: "play_button"), for: .normal)
                }
            }
        }
    }
    
    func playPause() {
        
        gSliderVolume = self.StreamVolume.value
        
        if let starplayr = player {
            //we know it's playing
            if starplayr.isBusy {
                Pause()
                //we know if officially on pause
            } else if let volume = gSliderVolume {
                PlayStream(volume: volume )
                lastchannel = currentChannel
            }
        }
    
        self.updatePlayPauseIcon(play: false)
    }
    
    @objc func doubleTapped() {
        playPause()
    }
   
    //View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Pause Gesture
        let doubleFingerTapToPause = UITapGestureRecognizer(target: self, action: #selector(PlayerViewController.doubleTapped) )
        doubleFingerTapToPause.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleFingerTapToPause)
        setAlbumArt = false
        
        StreamVolume.setThumbImage(UIImage(named: "knob")!, for: .normal)
        StreamVolume.setThumbImage(UIImage(named: "knob")!, for: .highlighted)
        
        let deviceType = UIDevice().type
        var multiplier = CGFloat()
        var zoomed = false
        
        //iPhone 8 Plus and zoomed
        if (UIScreen.main.bounds.size.height == 667.0 && UIScreen.main.nativeScale > UIScreen.main.scale){
            zoomed = true
        //iPhone 8 and zoomed
        } else if (UIScreen.main.bounds.size.height == 568.0 && UIScreen.main.nativeScale > UIScreen.main.scale) {
            zoomed = true
        }
        
        if deviceType == .iPhoneX {
            multiplier = CGFloat(0.999999) // just under 1 works
            ArtistSongViewTop.constant = 15 // add some space to the top
            SongLabelTop.constant = 0
            AlbumArtTop.constant = 15

        } else if deviceType == .iPhoneXSMax {
            multiplier = CGFloat(0.999999) // just under 1 works
            ArtistSongViewTop.constant = 20 // add even more space to the top
            SongLabelTop.constant = 5
            AlbumArtTop.constant = 15
            
        } else if deviceType == .iPhone8Plus {
            multiplier = CGFloat(0.999999) // just under 1 works
            ArtistSongViewTop.constant = 0 // add even more space to the top
            AlbumArtTop.constant = 0
            SongLabelTop.constant = 0
            SongLabelBottom.constant = 0
            
        } else if deviceType == .iPhone8 && !zoomed || deviceType == .iPhone8Plus && zoomed {
            multiplier = CGFloat(0.9)
        } else if deviceType == .iPhoneSE || deviceType == .iPhone8 && zoomed  {
            multiplier = CGFloat(0.75)
        } else if deviceType == .iPad {
            multiplier = CGFloat(0.7) // just under 1 works
            ArtistSongViewTop.constant = 0 // add some space to the top
            AlbumArtCenterX.constant = -30
            SongLabelTop.constant = 0
            AlbumArtTop.constant = 0
            SongLabelBottom.constant = 0
        }
 
        if multiplier != 0 {
            self.albumArt?.translatesAutoresizingMaskIntoConstraints = false
            self.albumArt?.addConstraint(NSLayoutConstraint(
                item: self.albumArt as Any, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: self.albumArt, attribute: NSLayoutConstraint.Attribute.width, multiplier: multiplier, constant: 0))
        }
    }
    
    
    @objc func OnDidStartPlaying(_ notification:Notification){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.startPlayer()
            self.updatePlayPauseIcon(play: false)
        }
    }
    
    
    @objc func OnDidPlayPause(_ notification:Notification){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.playPause()
        }
    }
    
    @objc func OnDidUpdatePlay(_ notification:Notification){
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            
            if let pbi = self.PlayButtonImage  {
                pbi.setImage(UIImage(named: "pause_button"), for: .normal)
            }
        }
    }
    
    
    @objc func OnDidUpdatePause(_ notification:Notification){
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            
            if let pbi = self.PlayButtonImage  {
                pbi.setImage(UIImage(named: "play_button"), for: .normal)
            }
        }
    }
    
    
    override func accessibilityPerformMagicTap() -> Bool {
        playPause()
        self.updatePlayPauseIcon(play: false)
        
        return true
    }
    
    
    func resizeLargeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 450, height: 450)
        
        UIGraphicsBeginImageContextWithOptions( targetSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    //
    @objc func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            print("Interruption began, take appropriate actions")

            // Interruption began, take appropriate actions
        }
        else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Interruption Ended - playback should resume
                    
                    print("Interruption Ended - playback should resume")
                    playPause()
                } else {
                    print("Interruption Ended - playback should NOT resume")

                    // Interruption Ended - playback should NOT resume
                }
            }
        }
    }
    
    @objc func GotNowPlayingInfo(_ notification:Notification){
       // PutNowPlayingInfo()
        PutNowPlayingInfo()
    }
    
    @objc func PutNowPlayingInfo(){
        
        UILabel.transition(with: self.ArtistLabel,
                          duration:0.333333,
                          options: .transitionCrossDissolve,
                          animations: { self.ArtistLabel.text = nowPlaying.artist },
                          completion: nil)
        
        UILabel.transition(with: self.SongLabel,
                           duration:0.333333,
                           options: .transitionCrossDissolve,
                           animations: { self.SongLabel.text = nowPlaying.song },
                           completion: nil)
        
        ArtistLabel.accessibilityLabel = nowPlaying.artist + ". " + nowPlaying.song + "."
        
        ArtQueue.async { [weak self] in
            
            guard let self = self else {return}
            let returndata = self.updateNowPlaying3()

            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else {return}
                
                if (returndata.setImage && returndata.image.size.width > 0) {
                    
                    UIView.transition(with: self.albumArt,
                                    duration:0.333333,
                                    options: .transitionCrossDissolve,
                                    animations: { self.albumArt.image = returndata.image },
                                    completion: nil)
                    
                    setnowPlayingInfo(channel:nowPlaying.name , song: nowPlaying.song, artist: nowPlaying.artist, imageData: returndata.image)
                }
            }
        }
    }
    
    
    //loading the album art
    func updateNowPlaying3() -> (setImage: Bool, image: UIImage) {
        
        var updateImage = false
        var getImage = UIImage()
        
        if self.preArtistSong != nowPlaying.artist + nowPlaying.song {
            self.setAlbumArt = false
            self.maxAlbumAttempts = 0
        }
        
        if self.maxAlbumAttempts < 3 || !self.setAlbumArt || self.localChannelArt != nowPlaying.albumArt || self.preArtistSong != nowPlaying.artist + nowPlaying.song  {
            
            var imageData : UIImage? = UIImage()
            
            if nowPlaying.albumArt.contains(string: "http://")  && nowPlaying.albumArt != "" {
                imageData = ImageSync(endpoint: nowPlaying.albumArt, method: "image") as UIImage
            }
        
            if imageData?.size.width == 0 || imageData?.size.height == 0 && nowPlaying.channelArt.contains(string: "http://")  {
                nowPlaying.albumArt = nowPlaying.channelArt
                imageData = ImageSync(endpoint: nowPlaying.albumArt, method: "image") as UIImage
                self.maxAlbumAttempts = self.maxAlbumAttempts + 1
                
                //when things go terribly wrong
                if imageData?.size.width == 0 || imageData?.size.height == 0 {
                    imageData = UIImage(named: "starplayr_placeholder")
                }
            } else {
                
                self.preArtistSong = (nowPlaying.artist + nowPlaying.song)
                self.localChannelArt = nowPlaying.albumArt
                self.maxAlbumAttempts = 3 // we know we set the art
                self.setAlbumArt = true
            }
            
            if imageData!.size.width != 0 && imageData!.size.height != 0 {
                updateImage = true
                let newImage = imageData!.withBackground(color: UIColor(displayP3Red: 19 / 255, green: 20 / 255, blue: 36 / 255, alpha: 1.0))
                getImage = self.resizeLargeImage(image: newImage, targetSize: CGSize(width: 450, height: 450))
            }
        }
        
        return(setImage: updateImage, image: getImage)
    }
}

