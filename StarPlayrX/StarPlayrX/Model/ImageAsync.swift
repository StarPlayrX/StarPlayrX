//
//  DataSync.swift
//  Cameoflage
//
//  Created by Todd on 1/27/19.
//

import Foundation
import UIKit

internal func ImageAsync(endpoint: String, ImageHandler: @escaping ImageHandler ) {
    
    func getURLRequest() -> URLRequest? {
        if let url = URL(string: endpoint) {
            var urlReq = URLRequest(url: url)
            urlReq.httpMethod = "GET"
            urlReq.timeoutInterval = TimeInterval(15)
            urlReq.cachePolicy = .returnCacheDataElseLoad
            return urlReq
        }
        
        return nil
    }
    
    let task = URLSession.shared.dataTask(with: getURLRequest()! ) { ( image, _, _ ) in
        
        image == .none ? ImageHandler(.none) : ImageHandler(UIImage(data: image!))
        
    }
    
    task.resume()

}
