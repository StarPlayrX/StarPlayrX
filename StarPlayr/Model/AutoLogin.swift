//
//  AutoLogin.swift
//  StarPlayr
//
//  Created by Todd on 4/9/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation
import AVKit
import CameoKit


private let LoginQueue = DispatchQueue(label: "LoginQueue", qos: .userInteractive, attributes: .concurrent)

//1
func autoLoginUpdate(playRadio: Bool) {
    autoLogin()
}


func autoLogin() {
    print(0)

    loginUpdate()
}

func loginUpdate() {
    print(1)
    LoginQueue.async {
        let returnData = loginHelper(username: gUsername, password: gPassword)
        DispatchQueue.main.async {
            if returnData.success {
                
                UserDefaults.standard.set(gUsername, forKey: "user")
                UserDefaults.standard.set(gPassword, forKey: "pass")
                
                userid = returnData.data
                
                UserDefaults.standard.set(userid, forKey: "userid")
                
                sessionUpdate()
                
               
            } else {
                print(returnData)
            }
        }
    }
}

func sessionUpdate() {
    print(3)

    LoginQueue.async {
        let _ = session()
        DispatchQueue.main.async {
            magicTapped()
        }
    }
}

func channelUpdate() {
    print(4)

    LoginQueue.async {
        let returnData = getChannelList()
        DispatchQueue.main.async {
            if returnData.success {
                channelList = (returnData.data as! [String : Any])
                artworkUpdate()
            }
        }
    }
}

func artworkUpdate() {
  print(5)
    LoginQueue.async {
        if let readData = UserDefaults.standard.data(forKey:  "spx_channelData") {
            let chData = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(readData)
            channelData = (chData as! [String : Data])
            updatingChannels()
        }
    }
}

func updatingChannels() {
    print(6)

    LoginQueue.async {
        processChannelList()
        DispatchQueue.main.async {
            channelGuide()
        }
    }
}

func channelGuide() {
    print(7)

    LoginQueue.async {
        
        let returnData = updatePDT2(importData: data!, category: "All", updateScreen: false, updateCache: false)
        
        if returnData.count > 0 {
            data = tableData()
            data = returnData
        }
        
        DispatchQueue.main.async {
            magicEightBall()
        }
    }
}

func magicEightBall() {
    print(8)

    magicTapped()
}

