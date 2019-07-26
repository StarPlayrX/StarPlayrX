//
//  Cookies.swift
//  StarPlayr
//
//  Created by Todd on 1/26/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation
import CameoKit

public func cookies(channelid: String, userid: String) -> (success: Bool, message: String, data: String) {
    var success = false
    var message = "Username or password is incorrect."
    var data = ""
    
    let endpoint = insecure + local + ":" + String(port) + "/api/v2/session"
    let method = "cookies"
    let request = ["channelid":channelid, "userid":userid] as Dictionary
    
    let result = PostSync(request: request, endpoint: endpoint, method: method )
    
    message = result.data["message"] as! String
    success = result.data["success"] as! Bool
    data = result.data["data"] as! String
    //print(success, message, data)
    
    return (success: success, message: message, data: data)
}
