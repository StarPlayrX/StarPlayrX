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
    var syncData : Data = Data()
    
    func getURLRequest() -> URLRequest? {
        if let url = URL(string: endpoint) {
            var urlReq = URLRequest(url: url)
            urlReq.httpMethod = "GET"
            urlReq.timeoutInterval = TimeInterval(30)
            return urlReq
        }
        
        return nil
    }
    
    let task = URLSession.shared.dataTask(with: getURLRequest()! ) { ( data, _, _ ) in
        
        if let data = data {
            syncData = data
        }
        
        //MARK: for Sync
        semaphore.signal()
    }
    
    task.resume()
    
    //MARK: for Sync
    _ = semaphore.wait(timeout: .distantFuture)
    
    return syncData
}

