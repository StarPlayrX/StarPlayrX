//
//  Login.swift
//  StarPlayrRadioApp
//
//  Created by Todd Bruss on 9/5/22.
//

import Foundation

func sessionRoute() -> ((HttpRequest) -> HttpResponse) {
    return { request in
        let json = try? JSONSerialization.jsonObject(with: Data(request.body), options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:String]
        
        guard
            let channelid = json?["channelid"]
        else {
            return HttpResponse.ok(.data(Data(), contentType: "application/json"))
        }
        
        let returnData = Session(channelid: channelid)
        if !returnData.isEmpty { storeCookiesX() }
    
        let object = ["data": returnData, "message": "coolbeans", "success": true] as [String : Any]
        let data = try! JSONSerialization.data(withJSONObject: object)
        return HttpResponse.ok(.data(data, contentType: "application/json"))
    }
}
