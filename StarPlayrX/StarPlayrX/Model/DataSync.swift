//
//  DataSync.swift
//  StarPlayrX
//
//  Created by Todd on 1/27/19.
//

import Foundation

internal func DataSync(endpoint: String, method: String ) -> Data {
    
    //MARK: for Sync
    let semaphore = DispatchSemaphore(value: 0)
    var syncData : Data? = Data()
    let http_method = "GET"
    let time_out = 30
    
    func getURLRequest() -> URLRequest? {
        if let url = URL(string: endpoint) {
            var urlReq = URLRequest(url: url)
            urlReq.httpMethod = http_method
            urlReq.timeoutInterval = TimeInterval(time_out)
            return urlReq
        }
        
        return nil
    }
    
    if let urlReq = getURLRequest() {
        
        let task = URLSession.shared.dataTask(with: urlReq ) { ( data, response, error ) in
            var status : Int? = 400
            
            if let response = response, let data = data {
                let result = response as? HTTPURLResponse
                status = result?.statusCode
                
                if status == 200  {
                    syncData = data
                }
            }
            
            //MARK: for Sync
            semaphore.signal()
        }
        
        task.resume()
    }
    
    //MARK: for Sync
    _ = semaphore.wait(timeout: .distantFuture)
    
    if let data = syncData {
        return data
    }
    
    return Data()
}

