import Foundation

internal func TextSync(endpoint: String, method: String ) -> String {
    
    //MARK - for Sync
    let semaphore = DispatchSemaphore(value: 0)
    
    var syncData = String()
    
    let http_method = "GET"
    let time_out = 30
    
    let url = URL(string: endpoint)
    var urlReq = URLRequest(url: url!)
    
    urlReq.httpMethod = http_method
    urlReq.timeoutInterval = TimeInterval(time_out)
    
    let task = URLSession.shared.dataTask(with: urlReq ) { ( returndata, response, error ) in
        
        var status = 400
        if response != nil {
            let result = response as! HTTPURLResponse
            status = result.statusCode
        }
        
        if status == 200 {
            
            do { let result =
                String(NSString(data: returndata!, encoding: String.Encoding.utf8.rawValue)!)
                
                syncData = result

            } 
        } else {
            syncData = "403"
        }
        
        //MARK - for Sync
        semaphore.signal()
    }
    
    
  
    
    task.resume()
    
    //MARK - for Sync
    _ = semaphore.wait(timeout: .distantFuture)
    
    return syncData

    
}

