//
//  keyOneRoute.swift
//  StarPlayrRadioApp
//
//  Created by Todd Bruss on 9/5/22.
//

import Foundation

func keyOneRoute() -> ((HttpRequest) -> HttpResponse) {
    return { request in
        guard let data = Data(base64Encoded: userX.key) else {
            return HttpResponse.ok(.data(Data(), contentType: "application/octet-stream"))
        }
        
        return HttpResponse.ok(.data(data, contentType: "application/octet-stream"))
    }
}