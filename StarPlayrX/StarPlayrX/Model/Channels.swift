//
//  Channels.swift
//  StarPlayr
//
//  Created by Todd on 1/26/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation
import CameoKit

public func channels(channeltype: String) -> (success: Bool, message: String, data: NSDictionary) {
    let success = false
    let message = "There was a problem retrieving the channels."
    let data = NSDictionary()
    
    let endpoint = insecure + local + ":" + String(Player.shared.port) + "/api/v2/channels"
    let method = "channels"
    let request = ["channeltype" : channeltype ] as Dictionary
    let result = PostSync(request: request, endpoint: endpoint, method: method )
    
    if let message = result.data["message"] as? String, let success = result.data["success"] as? Bool, let data = result.data["data"] as? NSDictionary {
        return (success: success, message: message, data: data)
    }
    

    return (success: success, message: message, data: data)
}
