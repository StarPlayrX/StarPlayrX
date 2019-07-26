//
//  Channels.swift
//  StarPlayr
//
//  Created by Todd on 1/26/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation
import CameoKit

public func channels(channeltype: String, userid: String) -> (success: Bool, message: String, data: NSDictionary) {
    var success = false
    var message = "There was a problem retrieving the channels."
    var data = NSDictionary()
    
    let endpoint = insecure + local + ":" + String(port) + "/api/v2/channels"
    let method = "channels"
    let request = ["channeltype" : channeltype, "userid" : userid ] as Dictionary
    let result = PostSync(request: request, endpoint: endpoint, method: method )
    
    message = result.data["message"] as! String
    success = result.data["success"] as! Bool
    data = result.data["data"] as! NSDictionary
    
    return (success: success, message: message, data: data)
}
