//
//  Xtra.swift
//  StarPlayr
//
//  Created by Todd on 3/31/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation
import CameoKit

//login User
public func xtraTune(channelGuid: String) -> (success: Bool, message: String, data: Data) {
    
    var success : Bool?     = false
    var message : String?   = "Network error, unable to continue."
    var data    : Data?     = Data()
    
    let endpoint = insecure + local + ":" + String(port) + "/api/xtra/tune/" + channelGuid
    
    data = DataSync(endpoint: endpoint, method: "xtraTune" )
    
    if data!.count > 1 {
        success = true
        message = "Returning Data"
    }

    return (success: success!, message: message!, data: data!)
}

