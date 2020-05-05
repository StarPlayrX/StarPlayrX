import Foundation

internal func TextSync(endpoint: String, TextHandler: @escaping TextHandler)  {
    guard let url = URL(string: endpoint) else { TextHandler("error"); return}
    
    var urlReq = URLRequest(url: url)
    urlReq.httpMethod = "GET"
    urlReq.timeoutInterval = TimeInterval(2)
    urlReq.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    
    let task = URLSession.shared.dataTask(with: urlReq ) { ( data, _, _ ) in
        
        guard
            let d = data,
            let text = String(data: d, encoding: .utf8)
            else { TextHandler("error"); return }
        
        TextHandler(text)
    }
    
    task.resume()
}




