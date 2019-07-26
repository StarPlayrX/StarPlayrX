//
//  PostSync.swift
//  StarPlayrX
//
//  Created by Todd on 1/25/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation

typealias PostReturnTuple = (message: String, success: Bool, data: NSDictionary, response: HTTPURLResponse )

internal func PostSync(request: Dictionary<String, Any>, endpoint: String, method: String) -> PostReturnTuple  {
 
    //MARK - for Sync
    let semaphore = DispatchSemaphore(value: 0)
    var syncData : PostReturnTuple? = (message: "", success: false, data: [:], response: HTTPURLResponse() )
    let http_method = "POST"
    let time_out = 30
    let url = URL(string: endpoint)
    var urlReq : URLRequest? = URLRequest(url: url!)
    
    if urlReq != nil {
        urlReq!.httpBody = try? JSONSerialization.data(withJSONObject: request, options: .prettyPrinted)
        urlReq!.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlReq!.httpMethod = http_method
        urlReq!.timeoutInterval = TimeInterval(time_out)
        urlReq!.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0.2 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        let task = URLSession.shared.dataTask(with: urlReq! ) { ( returndata, resp, error ) in
            
            if resp != nil && (resp as? HTTPURLResponse)!.statusCode == 200 {
                
                do { let result =
                    try JSONSerialization.jsonObject(with: returndata!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary

                    var localCats = Array<String>()
                    
                    if (method == "channels") {
                        if let cats = result!["categories"] as? Array<String> {
                            localCats = cats
                            localCats = localCats.sorted()
                        }
                        
                        var sportsTalk : Array<String> = ["Sports"]
                        var musicArray : Array<String> = ["Pop","Rock","Hip-Hop/R&B"]
                        var talkArray = Array<String>()
                        var miscArray : Array<String> = ["All"]

                        
                        if localCats.count > 2 {
                            
                            let max = localCats.count - 1

                            for i in 0...max  {
                                
                                
                                switch localCats[i] {
                                case "Rock","Pop","Sports","Hip-Hop/R&B":
                                    _ = localCats[i]; // presets /do nothing
                                case "Dance/Electronic","Latino","Country","Jazz","Punk","Oldies","Family","Christian","Classical","Metal","Alternative","Artists":
                                    //add to musicArray
                                    musicArray.append(localCats[i])
                                case "Canadian","More":
                                    _ = localCats[i]; // presets /do nothing
                                    miscArray.append(localCats[i])
                                case "Comedy","Entertainment","Howard Stern","News/Public Radio","Politics/Issues","Religion":
                                    _ = localCats[i]; // presets /do nothing
                                    talkArray.append(localCats[i])
                                case "MLB","NBA","NFL","NHL","Play-by-Play":
                                    _ = localCats[i]; // presets /do nothing
                                    sportsTalk.append(localCats[i])
                                default:
                                    
                                    //default to music as a catch all
                                    musicArray.append(localCats[i])
                                    //category = category
                                }
                                
                                
                                
                            }
                        }
                       
                        
                        if sportsTalk.count > 0 {
                            SportsCategories = sportsTalk
                        }
                        
                        if musicArray.count > 0 {
                            MusicCategories = musicArray
                        }
                        
                        if talkArray.count > 0 {
                            TalkCategories = talkArray
                        }
                        
                        if miscArray.count > 0 {
                            MiscCategories = miscArray
                        }
                    }
                    
                    syncData = (message: method + " was successful.", success: true, data: result, response: resp as! HTTPURLResponse ) as? PostReturnTuple
                } catch {
                    //fail on any errors
                    syncData = (message: method + " failed in do try catch.", success: false, data: ["": ""], response: resp as! HTTPURLResponse )
                }
            } else {
                //we always require 200 on the post, anything else is a failure
                
                if resp != nil {
                    syncData = (message: method + " failed, see response.", success: false, data: ["": ""], response: resp as! HTTPURLResponse ) as PostReturnTuple
                } else {
                    syncData = (message: method + " failed, no response.", success: false, data: ["": ""], response: HTTPURLResponse() ) as PostReturnTuple
                }
            }
            
            //MARK - for Sync
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: .distantFuture)
    }
    
    urlReq = nil
    
    if syncData != nil {
        return syncData!
    }
    
    return (message: method + " failed!", success: false, data: ["Error": "Fatal Error"], response: HTTPURLResponse() ) as PostReturnTuple
}


