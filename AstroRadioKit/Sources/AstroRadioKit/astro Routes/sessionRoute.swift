//
//  Login.swift
//  StarPlayrRadioApp
//
//  Created by Todd Bruss on 9/5/22.
//

import Foundation
import SwifterLite

func sessionRoute() -> httpReq {{ request in
    autoreleasepool {
        let json = try? JSONSerialization.jsonObject(with: Data(request.body), options: JSONSerialization.ReadingOptions.fragmentsAllowed) as? [String:String]
        
        guard
            let channelid = json?["channelid"]
        else {
            return HttpResponse.notFound(.none)
        }
        
        let returnData = Session(channelid: channelid)
        if !returnData.isEmpty { storeCookiesX() }
        
        let obj = ["data": returnData, "message": "coolbeans", "success": true] as [String : Any]
        
        return HttpResponse.ok(.json(obj))
    }
}}
