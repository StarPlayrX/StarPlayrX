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
        Player.shared.pause()
    }
    
    override func accessibilityPerformMagicTap() -> Bool {
        Player.shared.magicTapped()
        return true
    }
    
    func autoLogin() {
        
        let net = Networkability.shared
        
        //MARK: 1 - Logging In
        
        self.loginButton.isEnabled = false
        self.loginButton.alpha = 0.5
        self.view?.endEditing(true)
        
        var ping : String? = nil
        let pingUrl = "http://localhost:" + String(Player.shared.port) + "/ping"
        Async.api.Text(endpoint: pingUrl, TextHandler: { (p) -> Void in
            
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
        Player.shared.updatePDT_skipCheck(completionHandler: { (success) -> Void in
            if success {
                
                if let i = channelArray.firstIndex(where: {$0.channel == self.g.currentChannel}) {
                    let item = channelArray[i].largeChannelArtUrl
                    Player.shared.updateDisplay(key: self.g.currentChannel, cache: Player.shared.pdtCache, channelArt: item)
                }
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .updateChannelsView, object: nil)
                }
            }
        })
    }
    
    func prog(_ Float: Float, _ Text: String, animated: Bool = true) {
        DispatchQueue.main.async {
            
            let bar = self.progressBar?.progress

            let value = (Float < 1 && Float > 0) ? bar! + 0.1 : Float
            self.StatusField.text = Text
            self.progressBar?.setProgress(value, animated: true)
        }
    }
    
    func loginUpdate() {
        let endpoint = g.insecure + g.local + ":" + String(Player.shared.port)  + "/api/v2/autologin"
        let method = "login"
        let request = ["user":g.Username,"pass":g.Password] as Dictionary
        
        Async.api.Post(request: request, endpoint: endpoint, method: method, TupleHandler: { (result) -> Void in
            if let data = result?.data?["data"] as! String?,  let message = result?.data?["message"] as! String?, let success = result?.data?["success"] as! Bool?  {
                
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
        let endpoint = g.insecure + Global.obj.local + ":" + String(Player.shared.port) + "/api/v2/session"
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
        
        let endpoint = g.insecure + g.local + ":" + String(Player.shared.port) + "/api/v2/channels"
        let method = "channels"
        let request = ["channeltype" : "" ] as Dictionary
        
        Async.api.Post(request: request, endpoint: endpoint, method: method, TupleHandler: { ( result ) -> Void in
            if let data = result?.data?["data"] as? [String : Any] {
                self.g.channelList = data
                
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
            
            Async.api.Text(endpoint: checksumUrl, TextHandler: { (sum) -> Void in
                
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
                                        channelData = cd
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
                        
                        Async.api.CommanderData(endpoint: dataUrl, method: "large-art", DataHandler: { (data) -> Void in
                            if let data = data { d = data }
                        })
                        
                        //This error is near fatal, we will use the file on disk instead
                        if let chData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(d) {
                            
                            if let cdata = chData as? [String : Data] {
                                if cdata.count > 0 {
                                    channelData = cdata
                                    
                                    do {
                                        
                                        let writeData = try NSKeyedArchiver.archivedData(withRootObject: channelData as Any, requiringSecureCoding: false)
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
        channelArray = tableData()
        
        let g = Global.obj
        
        let sortedChannelList = Array(g.channelList.keys).sorted {$0.localizedStandardCompare($1) == .orderedAscending}
        let detail = NSMutableAttributedString(string: "\n" , attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]);
        let song = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]);
        detail.append(song)
        
        for ch in sortedChannelList {
            
            if let blueprint = g.channelList[ch] as? [String : Any],
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
                channelArray.append(item)
            }
        }
        
        let ps = Player.shared
        
        //Read in the presets
        let x = (UserDefaults.standard.array(forKey: "SPXPresets") ?? ["2","3","4"]) as [String]
        
        ps.SPXPresets = x
        if !ps.SPXPresets.isEmpty && !channelArray.isEmpty {
            var c = -1
            for t in channelArray {
                c += 1
                
                for p in ps.SPXPresets {
                    if p == t.channel {
                        channelArray[c].preset = true
                        break
                    }
                }
            }
        }
    }
    
    
    
    //Adds in Channel Art from Data Dictionary
    func processChannelIcons()  {
        if !channelArray.isEmpty && !channelData.isEmpty {
            for i in 0...channelArray.count - 1 {
                let channel = channelArray[i].channel
                if let chArt = channelData[channel], let img = UIImage(data: chArt) {
                    channelArray[i].channelImage = img
                    channelArray[i].image = img
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
        if let art = readLocalDataFile(filename: filename) {
            
            do {
                if let d = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData( art ) {
                    channelData = (d as! [String : Data]) //converts Any to [String : Data]
                }
            } catch {
                //the next step will run even if this fails
                print(error)
            }
        }
    }
    
    
    func textToImage(drawText: NSString, inImage: UIImage, atPoint: CGPoint) -> UIImage{
        //var inImage = inImage.withBackground(color: UIColor.black, opaque: false)
        let inImage = inImage.maskWithColor(color:  UIColor.clear )!
        
        // Setup the font specific variables
        let textColor = UIColor(displayP3Red: 0 / 255, green: 128 / 255, blue: 255 / 255, alpha: 0.875)
        let textFont = UIFont.systemFont(ofSize: 40)
        
        // Setup the image context using the passed image
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
        ]
        
        // Put the image into a rectangle as large as the original image
        inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))
        
        // Create a point within the space that is as bit as the image
        let rect = CGRect(x: atPoint.x, y: atPoint.y, width: inImage.size.width, height: inImage.size.height)
        
        // Draw the text into an image
        drawText.draw(in: rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage!
    }
    
    
    func simpleChannelArt() {
        let img = UIImage(named: "xplaceholder")!
        
        for c in channelData {
            var image:UIImage
            let w = CGFloat(0)
            
            let h = img.size.height / 4.25
            
            //let h = UIImage(data: c.value)!.size.height / 4.25
            image = self.textToImage( drawText: c.key as NSString, inImage: img, atPoint: CGPoint(x: w, y: h) )
            let imageData = image.pngData()
            channelData[c.key] = imageData
        }
    }
    
    
}


