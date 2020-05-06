//
//  Login.swift
//  StarPlayr
//
//  Created by Todd on 1/25/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//


import Foundation
import CameoKit
//login Helper Method
func loginHelper(username: String, password: String) -> (success: Bool, message: String, data: String) {
    
    if username != "" && password != "" {
        let loginTask = login(user: username, pass: password)
        return loginTask
    } else {
        return (success: false, message: "Please enter a username and password", data: "")
    }
}

func autoLoginHelper(username: String, password: String) -> (success: Bool, message: String, data: String) {
    
    if username != "" && password != "" {
        let loginTask = autologin(user: username, pass: password)
        return loginTask
    } else {
        return (success: false, message: "Please enter a username and password", data: "")
    }
}


//session Helper Method
func session() -> String {
    let cookiesTask = cookies(channelid: "siriushits1" )
    return cookiesTask.data
}



//login User
public func login(user: String, pass: String) -> (success: Bool, message: String, data: String) {
    var success = false
    var message = "Network error, unable to continue."
    var data = "411"
    
    let endpoint = insecure + local + ":" + String(Player.shared.port) + "/api/v2/login"
    let method = "login"
    let request = ["user":user,"pass":pass] as Dictionary
    
    let result = PostSync(request: request, endpoint: endpoint, method: method )
    if result.data?["message"] != nil {
        message = result.data?["message"] as! String
        success = result.data?["success"] as! Bool
        data = result.data?["data"] as! String
    } else {
        print("Error occurred logging in.")
    }
    
    //print(success, message, data)
    
    return (success: success, message: message, data: data)
}

//autologin
public func autologin(user: String, pass: String) -> (success: Bool, message: String, data: String) {
    var success = false
    var message = "Network error, unable to continue."
    var data = "411"
    
    let endpoint = insecure + local + ":" + String(Player.shared.port)  + "/api/v2/autologin"
    let method = "login"
    let request = ["user":user,"pass":pass] as Dictionary
    
    let result = PostSync(request: request, endpoint: endpoint, method: method )
    
    if result.data?["message"] != nil {
        message = result.data?["message"] as! String
        success = result.data?["success"] as! Bool
        data = result.data?["data"] as! String
    } else {
        print("Error occurred logging in.")
    }
    
    //print(success, message, data)
    
    return (success: success, message: message, data: data)
}
