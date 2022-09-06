//
//  channelsRoute.swift
//  StarPlayrRadioApp
//
//  Created by Todd Bruss on 9/5/22.
//

import Foundation

func channelsRoute() -> ((HttpRequest) -> HttpResponse) {
    return { request in
        let _ = Session(channelid: "siriushits1")
        let api = Channels()
        var data = Data()
        
        func runFailure() -> Data {
            let object = ["data": [:], "message": "Login failure.", "success": false] as [String : Any]
            let data = try! JSONSerialization.data(withJSONObject: object)
            return data
        }
        
        PostSync(request: api.request, endpoint: api.endpoint, method: api.method) { (result) in
            if let result = result {
                let returnData = processChannels(result: result)

                if returnData.success { storeCookiesX() }

                let object = ["data": returnData.data, "message": returnData.message, "success": returnData.success, "categories": returnData.categories] as [String : Any]
                
                data = try! JSONSerialization.data(withJSONObject: object)
            } else {
                data = runFailure()
            }
        }
        return HttpResponse.ok(.data(data, contentType: "application/json"))
    }
}
