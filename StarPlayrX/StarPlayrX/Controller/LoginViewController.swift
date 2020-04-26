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

private let LoginQueue = DispatchQueue(label: "LoginQueue", qos: .userInteractive, attributes: .concurrent)

class LoginViewController: UIViewController {

   
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
        autoLogin()
    }
    
    @objc func pausePlayBack() {
        Player.shared.pause()
    }
    
    override func accessibilityPerformMagicTap() -> Bool {
        Player.shared.magicTapped()
        return true
    }
    
    func autoLogin() {
        
        DispatchQueue.main.async {
            self.progressBar?.setProgress(0.0, animated: false)
            self.StatusField.text = "Logging In"
            self.progressBar?.setProgress(0.025, animated: true)
        }
        
        self.loginButton.isEnabled = false
        self.loginButton.alpha = 0.5
        self.view?.endEditing(true)
        
        let pingUrl = "http://localhost:" + String(Player.shared.port) + "/ping"
        let ping = TextSync(endpoint: pingUrl, method: "ping")
        
        //Check if Local Web Server is Up
        if ping == "403" || ping != "pong" {
            print("Launching the Server.")
            LaunchServer()
        }
        
        DispatchQueue.main.async {
            self.progressBar?.setProgress(0.05, animated: true)
        }
        
        DispatchQueue.main.async {
            self.loginUpdate()
        }
    }
    
    func loginUpdate() {
        DispatchQueue.main.async {
            self.progressBar?.setProgress(0.1, animated: true)
            
            if let user = self.userField.text, let pass = self.passField.text {
                gUsername = user
                gPassword = pass
                
                //login user
                let returnData = loginHelper(username: gUsername,
                                             password: gPassword)
                DispatchQueue.main.async {
                    if returnData.success {
                        UserDefaults.standard.set(gUsername, forKey: "user")
                        UserDefaults.standard.set(gPassword, forKey: "pass")
                        userid = returnData.data
                        UserDefaults.standard.set(userid, forKey: "userid")
                        
                        self.sessionUpdate()
                        
                    } else {
                        if returnData.data == "411" {
                            self.progressBar?.setProgress(0.0, animated: true)
                            self.closeStarPlayr(title: "Local Network Error",
                                                message: returnData.message, action: "Close StarPlayrX")
                        } else {
                            self.progressBar?.setProgress(0.0, animated: true)
                            self.showAlert(title: "Login Error",
                                           message: returnData.message, action: "OK")
                        }
                        self.loginButton.isEnabled = true
                        self.loginButton.alpha = 1.0
                    }
                }
            }
        }
    }
   
    
    func sessionUpdate() {
        LoginQueue.async {
            DispatchQueue.main.async {
                self.StatusField.text = "Success"
                self.progressBar?.setProgress(0.2, animated: true)
            }
            
            let returndata = session()
            DispatchQueue.main.async {
                self.channelUpdate(channelLineUpId:returndata)
            }
        }
    }
    
    
    func channelUpdate(channelLineUpId: String) {
        LoginQueue.async {
            DispatchQueue.main.async {
                self.StatusField.text = "Channels"
                self.progressBar?.setProgress(0.3, animated: true)
            }
            
            let returnData = getChannelList()
            if returnData.success {
                channelList = (returnData.data as! [String : Any])
                self.artworkUpdate(channelLineUpId: channelLineUpId)
            }
        }
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
    
    
    func artworkUpdate(channelLineUpId: String) {
        LoginQueue.async {
            
            DispatchQueue.main.async {
                self.StatusField.text = "Artwork"
                self.progressBar?.setProgress(0.4, animated: true)
            }
            
            self.embeddedAlbumArt(filename: "bluenumbers") //load by default
            
            demomode = false
            
            if demoname == gUsername {
                demomode = true
            } else {
                //large channel art checksum
                let GetChecksum = UserDefaults.standard.string(forKey: "largeChecksumXD") ?? binbytes

                //get large art checksum
                let checksumUrl = secure + domain + ":" + secureport2 + "/large/checksum"
                let lgChecksum = TextSync(endpoint: checksumUrl, method: "large-checksum")
                
                UserDefaults.standard.set(lgChecksum, forKey: "largeChecksumXD")
                
                if lgChecksum == GetChecksum {
                    
                    if String(lgChecksum) != websitedown || String(lgChecksum) != binbytes {
                        //demomode = true
                        
                        do {
                            if let readData = UserDefaults.standard.data(forKey: "channelDataXD") {
                                let chData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(readData)
                                if let cd = chData as? [String : Data] {
                                    
                                    if cd.count > 1 {
                                        channelData = cd
                                    } else {
                                        self.embeddedAlbumArt(filename: "demoart") //load by default
                                        demomode = true
                                    }
                                }
                            }
                        } catch {
                            self.embeddedAlbumArt(filename: "demoart") //load by default
                            demomode = true
                            print(error)
                        }
                    }
                } else if String(lgChecksum) != websitedown && String(lgChecksum) != binbytes && !demomode {
                    
                    do {
                        //If our website is down or the artwork server
                        
                        var dataUrl = secure + domain
                        dataUrl = dataUrl +  ":" + String(secureport2)
                        dataUrl = dataUrl + "/large"
                        
                        let d = DataSync(endpoint: dataUrl, method: "large-art")
                        
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
                        demomode = true
                        print(error)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.updatingChannels()
            }
        }
    }

    
    func updatingChannels() {
        LoginQueue.async {
            
            DispatchQueue.main.async {
                self.StatusField.text = "Icons"
                self.progressBar?.setProgress(0.55, animated: true)
            }
            
            processChannelList()
            
            DispatchQueue.main.async {
                self.progressBar?.setProgress(0.7, animated: true)
            }
            
            self.channelGuide()
        }
    }
    
    func channelGuide() {
        LoginQueue.async {
            
            DispatchQueue.main.async {
                self.StatusField.text = "Guide"
                self.progressBar?.setProgress(0.85, animated: true)
            }
            
            Player.shared.updatePDT(completionHandler: { (success) -> Void in
                // do nothing
                if success {
                    print("HELLOWORLD!")
                    
                  //do nothing
                }
            })
                        
            DispatchQueue.main.async {
                self.progressBar?.setProgress(0.9, animated: true)
            }
            
            self.loadArtwork()
        }
        
    }
    
    func loadArtwork() {
        LoginQueue.async {
            
            processChannelIcons()
            
            DispatchQueue.main.async {
                self.progressBar?.setProgress(1.0, animated: false)
                self.StatusField.text = "Complete"
                self.loginButton.isEnabled = true
                self.loginButton.alpha = 1.0
                self.tabItem(index: 1, enable: true, selectItem: true)
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
            self.tabBarController!.selectedIndex = index
        }
    }
    
    //view did load
    override func viewDidLoad() {
        
        super.viewDidLoad()
        Networkability().start()

        
       
  
        tabItem(index: 1, enable: false, selectItem: false)
        
        gUsername = UserDefaults.standard.string(forKey: "user") ?? ""
        gPassword = UserDefaults.standard.string(forKey: "pass") ?? ""
        userField.text = gUsername
        passField.text = gPassword
        
        //gUserid = UserDefaults.standard.string(forKey: "userid") ?? ""
        
        if !gUsername.isEmpty && !gPassword.isEmpty {
            
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


extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
}
