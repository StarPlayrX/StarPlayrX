import Foundation

//MARK: Text
internal func TextSync(endpoint: String, TextHandler: @escaping TextHandler) {
    guard let url = URL(string: endpoint) else { TextHandler("error1"); return}
    
    let semaphore = DispatchSemaphore(value: 0)

    var urlReq = URLRequest(url: url)
    urlReq.httpMethod = "GET"
    urlReq.timeoutInterval = TimeInterval(15)
    urlReq.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    
    let task = URLSession.shared.dataTask(with: urlReq ) { ( data, _, _ ) in
        
        guard
            let d = data,
            let text = String(data: d, encoding: .utf8)
            else { TextHandler("error2"); return }
        
        TextHandler(text)
        semaphore.signal()
    }
    
    task.resume()
    
    _ = semaphore.wait(timeout: .distantFuture)
}
