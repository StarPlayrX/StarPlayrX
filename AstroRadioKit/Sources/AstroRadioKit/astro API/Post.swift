//
//  Post.swift
//  Camouflage
//
//  Created by Todd on 1/25/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation

internal func PostSync(request: Dictionary<String, Any>, endpoint: String, method: String, PostTupleHandler: @escaping PostTupleHandler) {
    
    let dummy = (message: method + " failed in guard statement", success: false, data: ["": ""], response: nil ) as PostReturnTuple
    guard let url = URL(string: endpoint) else { PostTupleHandler(dummy); return }

    Session(channelid: "siriushits1")

    let semaphore = DispatchSemaphore(value: 0)
    var urlReq = URLRequest(url: url)
    
    if method != "channels" {
        urlReq.httpBody = try? JSONSerialization.data(withJSONObject: request, options: .prettyPrinted)
    }
    
    urlReq.addValue("application/json", forHTTPHeaderField: "Content-Type")
    urlReq.httpMethod = "POST"
    urlReq.timeoutInterval = TimeInterval(15)
    urlReq.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

    urlReq.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0.2 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
    
    let task = URLSession.shared.dataTask(with: urlReq ) { ( data, response, _ ) in
        
        //MARK: Here we are chaining multiple if lets, you can also be lazy with names one time only for each one
        if let response = response, let data = data, let http_url_response = response as? HTTPURLResponse {
            
            //MARK: Here we are unwrapping the result directly in the try statement
            do { if let result =
                
                try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, Any> {
                let return_tuple = (message: method + " was successful.", success: true, data: result, response: http_url_response ) as PostReturnTuple
                
                PostTupleHandler(return_tuple)
                }
            } catch {
                print("2")
                print(error)
                let dummy = (message: method + " failed in do try catch.", success: false, data: ["": ""], response: http_url_response ) as PostReturnTuple
                PostTupleHandler(dummy)
            }
        }
        
        //MARK - for Sync
        semaphore.signal()
    }
    
    task.resume()
    _ = semaphore.wait(timeout: .distantFuture)
}
