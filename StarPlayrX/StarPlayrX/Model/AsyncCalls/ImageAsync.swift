//
//  DataSync.swift
//  Cameoflage
//
//  Created by Todd on 1/27/19.
//

import Foundation
import UIKit

internal func ImageAsync(endpoint: String, ImageHandler: @escaping ImageHandler ) {
    guard let url = URL(string: endpoint) else { ImageHandler(.none); return }

    var urlReq = URLRequest(url: url)
    urlReq.httpMethod = "GET"
    urlReq.timeoutInterval = TimeInterval(2)
    urlReq.cachePolicy = .returnCacheDataElseLoad
    
    let task = URLSession.shared.dataTask(with: urlReq ) { ( data, _, _ ) in
        
        guard let d = data else { ImageHandler(.none); return }
        
        ImageHandler(UIImage(data: d))
    }
    
    task.resume()
}
