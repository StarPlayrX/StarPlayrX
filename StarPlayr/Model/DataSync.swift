//
//  DataSync.swift
//  StarPlayrX
//
//  Created by Todd on 1/27/19.
//

import Foundation

internal func DataSync(endpoint: String, method: String ) -> Data {
    
    //MARK - for Sync
    let semaphore = DispatchSemaphore(value: 0)
    
    var syncData : Data? = Data()
    
    let http_method = "GET"
    let time_out = 30
    
    let url = URL(string: endpoint)
    var urlReq : URLRequest? = URLRequest(url: url!)
    
    urlReq!.httpMethod = http_method
    urlReq!.timeoutInterval = TimeInterval(time_out)
    
    
    let task = URLSession.shared.dataTask(with: urlReq! ) { ( data, response, error ) in
        
        var status : Int? = 400
        
        if response != nil {
            let result = response as! HTTPURLResponse
            status = result.statusCode
        }
        
        
        if status == 200  {
            if data != nil {
                syncData = NSData(data: data!) as Data
            }
        }
        
        //MARK - for Sync
        semaphore.signal()
    }
    
    task.resume()
    
    //MARK - for Sync
    _ = semaphore.wait(timeout: .distantFuture)
    
    urlReq = nil
    
    if syncData != nil {
        return syncData!
    }
    
    return Data()
    
}
