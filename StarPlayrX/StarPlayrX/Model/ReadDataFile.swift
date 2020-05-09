//
//  readLocalDataFile.swift
//  StarPlayrX
//
//  Created by Todd Bruss on 7/29/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation

func readLocalDataFile(filename:String) -> Data?  {
    try? NSData(contentsOfFile: Bundle.main.path(forResource: filename, ofType: "dms")!) as Data
}

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



//How to programically change audio but follows the same rules as MPVolumeView which does not cover AirPlay2

/* Any one of these will work. applicationMusicPlayer is preferred
 
 let strV = String(describing: 0.25 )
 var mpc = MPMusicPlayerController.systemMusicPlayer
 mpc.setValue(strV, forKey: "volume" )
 
 var mpc2 = MPMusicPlayerController.applicationMusicPlayer
 mpc2.setValue(strV, forKey: "volume" )
 
 var mpc3 = MPMusicPlayerController.applicationQueuePlayer
 mpc3.setValue(strV, forKey: "volume" )
 
 var mpc4 = MPMusicPlayerController.iPodMusicPlayer
 mpc4.setValue(strV, forKey: "volume" )
 
 */
