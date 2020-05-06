//
//  Cookies.swift
//  StarPlayr
//
//  Created by Todd on 1/26/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation
import CameoKit

public func cookies(channelid: String) -> (success: Bool, message: String, data: String) {
    let success = false
    let message = "Username or password is incorrect."
    let data = ""
    
    let endpoint = insecure + local + ":" + String(Player.shared.port) + "/api/v2/session"
    let method = "cookies"
    let request = ["channelid":channelid] as Dictionary
    let result = PostSync(request: request, endpoint: endpoint, method: method )
    
    if let message = result.data?["message"] as? String,
        let success = result.data?["success"] as? Bool,
        let data = result.data?["data"] as? String {
        return (success: success, message: message, data: data)
    }
    
    return (success: success, message: message, data: data)
}
