//
//  LoginViewController.swift
//  StarPlayr
//
//  Created by Todd Bruss on 2/8/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import UIKit
import CameoKit
import AVKit


private let LoginQueue = DispatchQueue(label: "LoginQueue", qos: .userInteractive, attributes: .concurrent)

class LoginViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var StatusField: UILabel!
    
    @IBAction func UserFieldReturnKey(_ sender: Any) {
        //loginUser()
    }
    
    @IBAction func PassFieldReturnKey(_ sender: Any) {
        //loginUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //
        
    }
    
    //login button action
    @IBAction func loginButton(_ sender: Any) {
        autoLogin()
    }
    
    @objc func pausePlayBack() {
        Pause()
    }
    
    override func accessibilityPerformMagicTap() -> Bool {
        magicTapped()
        return true
    }
    
    func autoLogin() {
        progressBar?.setProgress(0.0, animated: false)
        
        LoginQueue.async {
            DispatchQueue.main.async {
                self.StatusField.text = "Logging In"
                self.progressBar?.setProgress(0.025, animated: true)
                
            }
        }
        
        self.loginButton.isEnabled = false
        self.loginButton.alpha = 0.5
        self.view?.endEditing(true)
        
        let pingUrl = "http://localhost:" + String(port) + "/ping"
        let ping = TextSync(endpoint: pingUrl, method: "ping")
        
        //Check if Local Web Server is Up
        if ping == "403" || ping != "pong" {
            startup = true;
            print("Launching the Server.")
            LaunchServer()
        }
        
        progressBar?.setProgress(0.05, animated: true)
        loginUpdate()
    }
    
    func loginUpdate() {
        
        self.progressBar?.setProgress(0.1, animated: true)
        let username = userField.text!
        let password = passField.text!
        LoginQueue.async {
            let returnData = loginHelper(username: username, password: password)
            DispatchQueue.main.async {
                if returnData.success {
                    
                    UserDefaults.standard.set(username, forKey: "user")
                    UserDefaults.standard.set(password, forKey: "pass")
                    
                    userid = returnData.data
                    
                    UserDefaults.standard.set(userid, forKey: "userid")
                    
                    self.sessionUpdate()
                } else {
                    if returnData.data == "411" {
                        self.closeStarPlayr(title: "Local Network Error", message: returnData.message, action: "Close StarPlayrX")
                    } else {
                        self.showAlert(title: "Login Error", message: returnData.message, action: "OK")
                    }
                    self.loginButton.isEnabled = true
                    self.loginButton.alpha = 1.0
                }
            }
        }
    }
    
    func sessionUpdate() {
        progressBar?.setProgress(0.2, animated: true)
        LoginQueue.async {
            let returndata = session()
            
            DispatchQueue.main.async {
                self.channelUpdate(channelLineUpId:returndata)
            }
        }
    }
    
    
    func channelUpdate(channelLineUpId: String) {
        self.StatusField.text = "Channels"
        progressBar?.setProgress(0.3, animated: true)
        LoginQueue.async {
            let returnData = getChannelList()
            DispatchQueue.main.async {
                if returnData.success {
                    channelList = (returnData.data as! [String : Any])
                    self.artworkUpdate(channelLineUpId: channelLineUpId)
                }
            }
        }
    }
    
    //read from Cache
    func readChannelData() {
        if let readData = UserDefaults.standard.data(forKey:  "spx_channelData") {
            let chData = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(readData)
            channelData = (chData as! [String : Data])
        } else {
            
            //If no Cache do it the hard way
            if let chList = channelList {
                let sortedChannelList = Array(chList.keys).sorted {$0.localizedStandardCompare($1) == .orderedAscending}
                for i in sortedChannelList {
                    if let channel = chList[i] as? NSDictionary {
                        let channelNumber = channel.value( forKeyPath: "channelNumber") as! String
                        let tinyImage = channel.value( forKeyPath: "tinyImage") as! String
                        let d = DataSync(endpoint: tinyImage, method: "imagedata")
                        
                        if var chData = channelData {
                            chData[channelNumber] = d
                        }
                    }
                }
            }
        }
    }
    
    
    func artworkUpdate(channelLineUpId: String) {
        self.StatusField.text = "Artwork"
        self.progressBar?.setProgress(0.4, animated: true)
        LoginQueue.async {
            
            var port = secureport
            
            if ( channelLineUpId != "400" ) {
                port = secureport2
            }
            //large channel art checksum
            
            let GetChecksum = UserDefaults.standard.string(forKey: "largeChecksum") ?? "-1"
            
            //get large art checksum
            let dataUrl = secure + domain + ":" + port + "/large/checksum"
            let lgChecksum = TextSync(endpoint: dataUrl, method: "large-checksum")
            var getLgArt = false
            
            if lgChecksum != GetChecksum && lgChecksum != "403" {
                getLgArt = true
                UserDefaults.standard.set(lgChecksum, forKey: "largeChecksum")
            }
            
            //print("Did we update art?", getLgArt,GetChecksum,lgChecksum)
            
            if getLgArt {
                do {
                    let dataUrl = secure + domain + ":" + port + "/large"
                    let lgArt = DataSync(endpoint: dataUrl, method: "large-art")
                    
                    if let chData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(lgArt) {
                        channelData = (chData as? [String : Data])
                    } else {
                        print("Something went wrong.")
                        self.readChannelData()
                    }
                } catch {
                    print(error)
                    self.readChannelData()
                }
            } else {
                if let readData = UserDefaults.standard.data(forKey:  "spx_channelData") {
                    let chData = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(readData)
                    channelData = (chData as! [String : Data])
                    
                } else {
                    //print("Awe snap!")
                    self.readChannelData()
                }
            }
            
            //get large art checksum
            /*
             let xdataUrl = secure + domain + ":" + port + "/xlarge/checksum"
             let xlgChecksum = TextSync(endpoint: xdataUrl, method: "xlarge-checksum")
             var getxLgArt = false
             
             if let xlargeChecksum = UserDefaults.standard.string(forKey: "xlargeChecksum") {
             if xlargeChecksum != xlgChecksum && xlgChecksum != "403" {
             getxLgArt = true
             print("xLgArt:",getxLgArt)
             
             }
             } else if xlgChecksum != "403" {
             getxLgArt = true
             print("xLgArtB:",getxLgArt,xlgChecksum)
             }
             
             
             if getxLgArt {
             do {
             let dataUrl2 = secure + domain + ":" + port + "/xlarge"
             let xlgArt = DataSync(endpoint: dataUrl2, method: "xlarge-art")
             
             if let chData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(xlgArt) {
             XLchannelData = (chData as? [String : Data])
             }
             } catch {
             print(error)
             }
             }
             */
            
            DispatchQueue.main.async {
                self.progressBar?.setProgress(0.5, animated: true)
                self.updatingChannels()
                LoginQueue.async {
                    let writeData = try! NSKeyedArchiver.archivedData(withRootObject: channelData as Any, requiringSecureCoding: false)
                    UserDefaults.standard.set(writeData, forKey: "spx_channelData")
                }
            }
        }
    }
    
    func updatingChannels() {
        progressBar?.setProgress(0.6, animated: true)
        LoginQueue.async {
            processChannelList()
            DispatchQueue.main.async {
                self.channelGuide()
            }
        }
    }
    
    func channelGuide() {
        progressBar?.setProgress(0.8, animated: true)
        LoginQueue.async {
            
            let returnData = updatePDT2(importData: data!, category: "All", updateScreen: false, updateCache: true)
            
            if returnData.count > 0 {
                //data = tableData()
                data = returnData
            }
            
            DispatchQueue.main.async {
                self.loadArtwork()
            }
        }
    }
    
    func loadArtwork() {
        progressBar?.setProgress(1.0, animated: true)
        LoginQueue.async {
            processChannelIcons()
            DispatchQueue.main.async {
                self.progressBar?.setProgress(1.0, animated: true)
                self.StatusField.text = "Login Complete"
                self.loginButton.isEnabled = true
                self.loginButton.alpha = 1.0
                self.tabItem(index: 1, enable: true, selectItem: true)
                self.StatusField.text = ""
            }
        }
    }
    
    
    //Show Alert
    func showAlert(title: String, message:String, action:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            @unknown default:
                print("error.")
            }}))
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
            self.tabBarController!.selectedIndex = index
        }
    }
    
    //view did load
    override func viewDidLoad() {
        
        Networkability().start()
        
        super.viewDidLoad()
        
        tabItem(index: 1, enable: false, selectItem: false)
        
        gUsername = UserDefaults.standard.string(forKey: "user") ?? ""
        gPassword = UserDefaults.standard.string(forKey: "pass") ?? ""
        userField.text = gUsername
        passField.text = gPassword
        
        gUserid = UserDefaults.standard.string(forKey: "userid") ?? ""
        
        if gUsername != "" && gPassword != "" && gUserid != "" {
            
            LoginQueue.async {
                
                if UIAccessibility.isVoiceOverRunning {
                    let utterance = AVSpeechUtterance(string: "Star Player X, Logging In")
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                    utterance.rate = 0.5
                    
                    let synthesizer = AVSpeechSynthesizer()
                    synthesizer.speak(utterance)
                }
            }
            
            autoLogin()
        }
        
        //Pause Gesture
        let doubleFingerTapToPause = UITapGestureRecognizer(target: self, action: #selector(pausePlayBack) )
        doubleFingerTapToPause.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleFingerTapToPause)
        
        
    }
    
}


