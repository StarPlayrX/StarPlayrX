import Foundation


internal func GetAsync(endpoint: String, DictionaryHandler: @escaping DictionaryHandler)  {
    guard let url = URL(string: endpoint) else { DictionaryHandler(.none); return}
    
    var urlReq = URLRequest(url: url)
    urlReq.httpMethod = "GET"
    urlReq.timeoutInterval = TimeInterval(15)
    urlReq.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    
    let task = URLSession.shared.dataTask(with: urlReq ) { ( returndata, response, _ ) in
        if let r = returndata {
            let dict = try? JSONSerialization.jsonObject(with: r, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            DictionaryHandler(dict)
        } else {
            DictionaryHandler(nil)
        }
    }
    
    task.resume()
    
}



