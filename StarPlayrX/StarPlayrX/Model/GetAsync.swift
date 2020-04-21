import Foundation


internal func GetAsync(endpoint: String, DictionaryHandler: @escaping DictionaryHandler)  {

    func getURLRequest() -> URLRequest? {
        if let url = URL(string: endpoint) {
            var urlReq = URLRequest(url: url)
            urlReq.httpMethod = "GET"
            urlReq.timeoutInterval = TimeInterval(15)
            urlReq.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            return urlReq
        }
        
        return nil
    }
    
    let task = URLSession.shared.dataTask(with: getURLRequest()! ) { ( returndata, response, _ ) in
        if let r = returndata {
            let dict = try? JSONSerialization.jsonObject(with: r, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            DictionaryHandler(dict)
        } else {
            DictionaryHandler(nil)
        }
    }
    
    task.resume()
    
}
