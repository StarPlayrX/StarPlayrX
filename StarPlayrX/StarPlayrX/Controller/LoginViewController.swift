//
//  LoginViewController.swift
//  StarPlayr
//
//  Created by Todd Bruss on 2/8/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import UIKit
import SafariServices
import AVKit


class LoginViewController: UIViewController {
    
    let g = Global.obj
    let p = Player.shared

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .bottom }
    override var prefersHomeIndicatorAutoHidden : Bool { return true }
    
    
    @IBAction func starplayrx_dot_com(_ sender: Any) {
        website(url: "https://starplayrx.com")
    }
    
    @IBAction func Trial(_ sender: Any) {
        website(url: "https://care.siriusxm.com/sirpromoplanselection_view.action?programCode=ESSPS3MOFREE&intcmp=NPR_all_SXIRES-launch_tryfree_3for0_040819_ES")
    }
    
    func website(url: String) {
        if let url = URL(string: url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var StatusField: UILabel!
    
    @IBAction func UserFieldReturnKey(_ sender: Any) {}
    @IBAction func PassFieldReturnKey(_ sender: Any) {}
    override func viewWillAppear(_ animated: Bool) {}
    
    //login button action
    @IBAction func loginButton(_ sender: Any) {
        g.Username = userField.text ?? ""
        g.Password = passField.text ?? ""
        autoLogin()
        prog(0.0, "Logging In")
    }
    
    @objc func pausePlayBack() {
        p.pause()
    }
    
    override func accessibilityPerformMagicTap() -> Bool {
        p.magicTapped()
        return true
    }
    
    func autoLogin() {
        
        let net = Network.ability
        
        //MARK: 1 - Logging In
        
        self.loginButton.isEnabled = false
        self.loginButton.alpha = 0.5
        self.view?.endEditing(true)
        
        var ping : String? = nil
        let pingUrl = "http://localhost:" + String(p.port) + "/ping"
        Async.api.Text(endpoint: pingUrl, TextHandler: { (p) in
            
            ping = p
            
            //Check if Local Web Server is Up
            if let pg = ping, pg != "pong" {
                print("Launching the Server.")
                net.LaunchServer()
            }
            
            self.loginUpdate()
        })
    }
    
    
    func channelGuide() {
        //MARK: Skip Check
        p.updatePDT(true, completionHandler: { (success) in
            if success {
                
                if let i = self.g.ChannelArray.firstIndex(where: {$0.channel == self.g.currentChannel}) {
                    let item = self.g.ChannelArray[i].largeChannelArtUrl
                    self.p.updateDisplay(key: self.g.currentChannel, cache: self.p.pdtCache, channelArt: item)
                }
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .updateChannelsView, object: nil)
                }
            }
        })
    }
    
    func prog(_ Float: Float, _ Text: String, animated: Bool = false) {
        DispatchQueue.main.async {
            //MARK: Invoke using getFloat(Float)
            let getFloat = { (_ Float: Float) -> Float in
                if let bar = self.progressBar?.progress {
                    return Float < 1 && Float > 0 ? bar + 0.1 : Float
                } else {
                    return Float
                }
            }
            
            let value = getFloat(Float) //return value
            
            
            self.StatusField.text = Text
            self.progressBar?.setProgress( value, animated: true)
        }
    }
    
    func loginUpdate() {
        let endpoint = g.insecure + g.local + ":" + String(p.port)  + "/api/v2/autologin"
        let method = "login"
        let request = ["user":g.Username,"pass":g.Password] as Dictionary
        
        Async.api.Post(request: request, endpoint: endpoint, method: method, TupleHandler: { (result) in
            if let data = result?.data?["data"] as? String,  let message = result?.data?["message"] as? String, let success = result?.data?["success"] as? Bool  {
                
                if success {
                    
                    //MARK: 2 - Logging In
                    self.prog(0.15, "Success")
                    
                    UserDefaults.standard.set(self.g.Username, forKey: "user")
                    UserDefaults.standard.set(self.g.Password, forKey: "pass")
                    self.g.userid = data
                    UserDefaults.standard.set(self.g.userid, forKey: "userid")
                    self.sessionUpdate()
                    
                } else {
                    if data == "411" {
                        
                        self.prog(0, "")
                        self.closeStarPlayr(title: "Local Network Error",
                                            message: message, action: "Close StarPlayrX")
                    } else {
                        self.prog(0, "")
                        self.showAlert(title: "Login Error",
                                       message: message, action: "OK")
                    }
                    
                    self.loginButton.isEnabled = true
                    self.loginButton.alpha = 1.0
                }
                
                
                
            } else {
                print("Error occurred logging in.")
            }
            
        })
        
        
        
        
    }
    
    
    func sessionUpdate() {
        let endpoint = g.insecure + Global.obj.local + ":" + String(p.port) + "/api/v2/session"
        let method = "cookies"
        let request = ["channelid":"siriushits1"] as Dictionary
        
        Async.api.Post(request: request, endpoint: endpoint, method: method, TupleHandler: { (result) -> Void in
            
            self.prog(0.3, "Channels")

            if let data = result?.data?["data"] as? String {
                self.channelUpdate(channelLineUpId:data)
            } else {
                self.channelUpdate(channelLineUpId:"350")
            }
            
        })
        
        
    }
    
    
    func channelUpdate(channelLineUpId: String) {
        
        let endpoint = g.insecure + g.local + ":" + String(p.port) + "/api/v2/channels"
        let method = "channels"
        let request = ["channeltype" : "" ] as Dictionary
        
        Async.api.Post(request: request, endpoint: endpoint, method: method, TupleHandler: { ( result ) -> Void in
            if let data = result?.data?["data"] as? [String : Any] {
                self.g.ChannelList = data
                
                self.prog(0.5, "Artwork")

                self.artworkUpdate(channelLineUpId: channelLineUpId)
            } else {
                //read channellist from disk?
                print("Error reading channels.")
            }
        })
        
    }
    
      
    func artworkUpdate(channelLineUpId: String) {
        let g = Global.obj
    
        self.embeddedAlbumArt(filename: "bluenumbers") //load by default
        
        g.demomode = false
        
        if g.demoname == g.Username {
            g.demomode = true
        } else {
            //large channel art checksum
            let GetChecksum = UserDefaults.standard.string(forKey: "largeChecksumXD") ?? g.binbytes
            
            //get large art checksum
            
            
            let checksumUrl = g.secure + g.domain + ":" + g.secureport + "/large/checksum"
            
            g.imagechecksum = ""
     
            Async.api.Text(endpoint: checksumUrl, TextHandler: { (sum) in
                
                self.prog(0.6, "Artwork")

                if let check = sum {
                    g.imagechecksum = String(check)
                } else {
                    g.imagechecksum = g.websitedown
                }
                
                art()
                self.updatingChannels()

            })
            
                        
            func art() {
                
                if g.imagechecksum == GetChecksum {
                    
                    if g.imagechecksum != g.websitedown || g.imagechecksum != String(g.binbytes) {
                        //demomode = true
                        
                        do {
                            if let readData = UserDefaults.standard.data(forKey: "channelDataXD") {
                                let chData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(readData)
                                if let cd = chData as? [String : Data] {
                                    
                                    if cd.count > 1 {
                                        g.ChannelData = cd
                                    } else {
                                        self.embeddedAlbumArt(filename: "demoart") //load by default
                                        g.demomode = true
                                    }
                                }
                            }
                        } catch {
                            self.embeddedAlbumArt(filename: "demoart") //load by default
                            g.demomode = true
                            print(error)
                        }
                    }
                } else if g.imagechecksum != g.websitedown && g.imagechecksum != String(g.binbytes) && !g.demomode {
                    
                    do {
                        //If our website is down or the artwork server
                        
                        let g = Global.obj
                        
                        var dataUrl = g.secure + g.domain
                        
                        dataUrl += ":" + String(g.secureport)
                        dataUrl += "/large"
                        
                        var d = Data()
                        
                        Async.api.CommanderData(endpoint: dataUrl, method: "large-art", DataHandler: { (data) in
                            if let data = data { d = data }
                        })
                        
                        //This error is near fatal, we will use the file on disk instead
                        if let chData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(d) {
                            
                            if let cdata = chData as? [String : Data] {
                                if cdata.count > 0 {
                                    g.ChannelData = cdata
                                    
                                    do {
                                        
                                        let writeData = try NSKeyedArchiver.archivedData(withRootObject: g.ChannelData as Any, requiringSecureCoding: false)
                                        UserDefaults.standard.set(writeData, forKey: "channelDataXD")
                                    } catch {
                                        //This is not a fatal error, we can recover from it
                                        //demomode = true
                                        print(error)
                                    }
                                }
                            }
                        }
                    } catch {
                        g.demomode = true
                        print(error)
                    }
                }
                
                UserDefaults.standard.set(g.imagechecksum, forKey: "largeChecksumXD")

            }

        }
        
    }
    
    
    func updatingChannels() {
        
        self.prog(0.75, "Guide")
		channelGuide()
        processChannelList()
        self.prog(0.875, "Artwork")
        self.loadArtwork()

    }
    
  
    func loadArtwork() {
        

        processChannelIcons()
    
        self.prog(1.0, "Complete")

        DispatchQueue.main.async {
            self.prog(1.0, "Complete")
            self.loginButton.isEnabled = true
            self.loginButton.alpha = 1.0
            self.tabItem(index: 1, enable: true, selectItem: true)
        }

    }
    
    
    func processChannelList()  {
        guard let channelList = g.ChannelList else { return }
        
        g.ChannelList = nil
        
        g.ChannelArray = tableData()
        
        let g = Global.obj
        
        let sortedChannelList = Array(channelList.keys).sorted {$0.localizedStandardCompare($1) == .orderedAscending}
        let detail = NSMutableAttributedString(string: "\n" , attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]);
        let song = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]);
        detail.append(song)
        
        for ch in sortedChannelList {
            
            if let blueprint = channelList[ch] as? [String : Any],
                let number = blueprint["channelNumber"] as? String,
                var name = blueprint["name"] as? String,
                let mediumImage = blueprint["mediumImage"] as? String,
                let category = blueprint["category"] as? String,
                let preset = blueprint["preset"] as? Bool,
                let tinyImageData = UIImage(named: "xplaceholder") {
                
                //We do not allow SiriusXM in channel names, plus it's kind of redundant
                name = name.replacingOccurrences(of: "SiriusXM", with: "Sirius")
                name = name.replacingOccurrences(of: "SXM", with: "SPX")
                
                let title = NSMutableAttributedString(string: number + " ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)])
                let channel = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)])
                
                title.append(channel)
                
                let item = (searchString: number + name , name: name, channel: number, title: title, detail: detail, image: tinyImageData, channelImage: tinyImageData, albumUrl: "", largeAlbumUrl: "", largeChannelArtUrl: mediumImage, category: category, preset: preset )
                g.ChannelArray.append(item)
            }
        }
        
        
        //Read in the presets
        let x = (UserDefaults.standard.array(forKey: "SPXPresets") ?? ["2","3","4"]) as [String]
        
        p.SPXPresets = x
        if !p.SPXPresets.isEmpty && !g.ChannelArray.isEmpty {
            var c = -1
            for b in g.ChannelArray {
                c += 1
                
                for a in p.SPXPresets {
                    if a == b.channel {
                        g.ChannelArray[c].preset = true
                        break
                    }
                }
            }
        }
    }
    
    
    
    //Adds in Channel Art from Data Dictionary
    func processChannelIcons()  {
        if !g.ChannelArray.isEmpty && !(g.ChannelData?.isEmpty ?? true) {
            for i in 0..<g.ChannelArray.count {
                let channel = g.ChannelArray[i].channel
                if let chArt = g.ChannelData?[channel], let img = UIImage(data: chArt) {
                    g.ChannelArray[i].channelImage = img
                    g.ChannelArray[i].image = img
                }
            }
        }
    }

    
    //Show Alert
    func showAlert(title: String, message:String, action:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default, handler: { action in
            /*switch action.style{
             case .default:
             print("default")
             case .cancel:
             print("cancel")
             case .destructive:
             print("destructive")
             @unknown default:
             print("error.")
             }*/}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func closeStarPlayr(title: String, message:String, action:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default, handler: { action in
            switch action.style{
                case .default:
                    exit(0)
                case .cancel:
                    print("cancel")
                case .destructive:
                    print("destructive")
                
                @unknown default:
                    print("error.")
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    //set tab item
    func tabItem(index: Int, enable: Bool, selectItem: Bool) {
        let tabBarArray = self.tabBarController?.tabBar.items
        
        if let tabBarItems = tabBarArray, tabBarItems.count > 0 {
            let tabBarItem = tabBarItems[index]
            tabBarItem.isEnabled = enable
        }
        
        if selectItem {
            self.tabBarController?.selectedIndex = index
        }
    }
    
    //view did load
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
        let g = Global.obj
        
        tabItem(index: 1, enable: false, selectItem: false)
        
        g.Username = UserDefaults.standard.string(forKey: "user") ?? ""
        g.Password = UserDefaults.standard.string(forKey: "pass") ?? ""
        userField.text = g.Username
        passField.text = g.Password
        
        //gUserid = UserDefaults.standard.string(forKey: "userid") ?? ""
        
        if !g.Username.isEmpty && !g.Password.isEmpty {
            
            if UIAccessibility.isVoiceOverRunning {
                let utterance = AVSpeechUtterance(string: "Star Player X, Logging In")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5
                
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
            }
            
            prog(0.0, "Logging In")

            autoLogin()
            
        }
        
        //Pause Gesture
        let doubleFingerTapToPause = UITapGestureRecognizer(target: self, action: #selector(pausePlayBack) )
        doubleFingerTapToPause.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleFingerTapToPause)
        
    }
    
    func embeddedAlbumArt(filename: String) {
        if let art = Sync.io.readLocalDataFile(filename: filename) {
            
            do {
                if let d = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData( art ),
                    let dict = (d as? [String : Data]) /* converts Any to [String : Data] */ {
                    g.ChannelData = dict
                }
            } catch {
                //the next step will run even if this fails
            	//MARK: To Do - Need to fix this
                print(error)
            }
        }
    }

}


