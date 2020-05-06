//
//  PostSync.swift
//  Camouflage
//
//  Created by Todd on 1/25/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation


 func PostSync(request: Dictionary<String, Any>, endpoint: String, method: String) -> PostReturnTuple  {
 
    //MARK - for Sync
    let semaphore = DispatchSemaphore(value: 0)
    var syncData : PostReturnTuple = (message: "", success: false, data: [:], response: HTTPURLResponse() )
    
    func getURLRequest() -> URLRequest? {
        if let url = URL(string: endpoint) {
            var urlReq = URLRequest(url: url)
            urlReq.httpBody = try? JSONSerialization.data(withJSONObject: request, options: .prettyPrinted)
            urlReq.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlReq.httpMethod = "POST"
            urlReq.timeoutInterval = TimeInterval(15)
            urlReq.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0.2 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
            return urlReq
        }
        
        return nil
    }
    
        let task = URLSession.shared.dataTask(with: getURLRequest()! ) { ( returndata, resp, error ) in
            
            if let rdata = returndata {
                
                    let result = try? JSONSerialization.jsonObject(with: rdata, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary

                    
                    if (method == "channels") {
                        var localCats = Array<String>()

                        if let cats = result?["categories"] as? Array<String> {
                            localCats = cats
                            localCats = localCats.sorted()
                        }
                        
                        let Popular: Array<String> = [Player.shared.allStars,Player.shared.everything]
                        var sportsTalk : Array<String> = ["Sports"]
                        var musicArray : Array<String> = ["Pop","Rock","Hip-Hop/R&B"]
                        var talkArray = Array<String>()
                        var miscArray = Array<String>()

                        
                        if !localCats.isEmpty {
                            
                            for i in 0...localCats.count - 1  {
                                
                                switch localCats[i] {
                                case "Rock","Pop","Sports","Hip-Hop/R&B":
                                    ()
                                case "Dance/Electronic","Latino","Country","Jazz","Punk","Oldies","Family","Christian","Classical","Metal","Alternative","Artists":
                                    //add to musicArray
                                    musicArray.append(localCats[i])
                                case "Canadian","More":
                                    miscArray.append(localCats[i])
                                case "Comedy","Entertainment","Howard Stern","News/Public Radio","Politics/Issues","Religion":
                                    talkArray.append(localCats[i])
                                case "MLB","NBA","NFL","NHL","Play-by-Play":
                                    sportsTalk.append(localCats[i])
                                default:
                                    //default to music as a catch all
                                    musicArray.append(localCats[i])
                                }
                            }
                        }
                       
                        if !Popular.isEmpty {
                            PopularCategories = Popular
                        }
                        
                        if !sportsTalk.isEmpty {
                            SportsCategories = sportsTalk
                        }
                        
                        if !musicArray.isEmpty {
                            MusicCategories = musicArray
                        }
                        
                        if !talkArray.isEmpty {
                            TalkCategories = talkArray
                        }
                        
                        if !miscArray.isEmpty {
                            MiscCategories = miscArray
                        }
                        
                    }
                    
                syncData = (message: method + " was successful.", success: true, data: result, response: resp as? HTTPURLResponse ) as PostReturnTuple
               
            }
            
            //MARK - for Sync
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: .distantFuture)
 
        
    return syncData
    
}


