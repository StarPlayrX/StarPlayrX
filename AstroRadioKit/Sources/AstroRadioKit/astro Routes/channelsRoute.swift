//
//  channelsRoute.swift
//  StarPlayrRadioApp
//
//  Created by Todd Bruss on 9/5/22.
//

import Foundation
import SwifterLite

func channelsRoute() -> httpReq {{ request in
    autoreleasepool {
        Session(channelid: "siriushits1")
        let api = Channels()
        var obj = [String : Any]()

        PostSync(request: api.request, endpoint: api.endpoint, method: api.method) { (result) in
            if let result = result {
                let returnData = processChannels(result: result)
                if returnData.success { storeCookiesX() }
                
                obj = ["data": returnData.data, "message": returnData.message, "success": returnData.success, "categories": returnData.categories] as [String : Any]
                
            } else {
                obj = ["data": [:], "message": "Login failure.", "success": false] as [String : Any]
            }
        }
        return HttpResponse.ok(.json(obj))
    }
}}
