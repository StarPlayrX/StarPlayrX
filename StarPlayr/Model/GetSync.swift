import Foundation

internal func GetSync(endpoint: String, method: String ) -> NSDictionary {
    
    //MARK - for Sync
    let semaphore = DispatchSemaphore(value: 0)

    var syncData : NSDictionary? = NSDictionary()
    
    let http_method = "GET"
    let time_out = 30
    
    let url = URL(string: endpoint)
    var urlReq: URLRequest? = URLRequest(url: url!)
    
    urlReq!.httpMethod = http_method
    urlReq!.timeoutInterval = TimeInterval(time_out)
    
    let task = URLSession.shared.dataTask(with: urlReq! ) { ( returndata, response, error ) in
        
        var status : Int? = 400
        if response != nil {
            let result = response as! HTTPURLResponse
            status = result.statusCode
        }
        
        if status == 200 {
            
            do { let result =
                try JSONSerialization.jsonObject(with: returndata!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                syncData = result as NSDictionary
                
            } catch {
                //
            }
        } else {
            // print(response)
        }
        
        status = nil
        
        //MARK - for Sync
        semaphore.signal()
    }
    
    task.resume()
    
    //MARK - for Sync
    _ = semaphore.wait(timeout: .distantFuture)
    

    urlReq = nil
    
    return syncData!
    
}



//to do:

// channel Data


