//
//  Login.swift
//  StarPlayrRadioApp
//
//  Created by Todd Bruss on 9/5/22.
//

import Foundation

func loginRoute() -> ((HttpRequest) -> HttpResponse) {
    return { request in
        
        let json = try? JSONSerialization.jsonObject(with: Data(request.body), options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any]
        
        guard
            let u = json?["user"] as? String,
            let p = json?["pass"] as? String
        else {
            let object = ["data": "Failed to login.", "message": "Login failure.", "success": false] as [String : Any]
            let data = try! JSONSerialization.data(withJSONObject: object)
            return HttpResponse.ok(.data(data, contentType: "application/json"))
        }
        let login = LoginX(username: u, pass: p)
        var data = Data()
        
        PostSync(request: login.request, endpoint: login.endpoint, method: login.method) { result in
            
            guard let result = result else { return }
            let returnData = processLogin(username: u, pass: p, result: result)
            if returnData.success {
                storeCookiesX()
            }
            
            let object = ["data": returnData.data, "message": returnData.message, "success": returnData.success] as [String : Any]

            data = try! JSONSerialization.data(withJSONObject: object)
        }
        
        return HttpResponse.ok(.data(data, contentType: "application/json"))
    }
}
