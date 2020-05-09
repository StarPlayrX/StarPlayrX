//
//  readLocalDataFile.swift
//  StarPlayrX
//
//  Created by Todd Bruss on 7/29/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation

class Sync {
    static let io = Sync()
    
    //MARK: Read a data file Synchronously
    func readLocalDataFile(filename:String) -> Data?  {
        try? NSData(contentsOfFile: Bundle.main.path(forResource: filename, ofType: "dms")!) as Data
    }
    
    //MARK: Read a text data Synchronously
    internal func TextSync(endpoint: String, method: String ) -> String {
        
        let textsync_error = "textSync-error="
        
        guard let url = URL(string: endpoint) else {return "\(textsync_error)=0" }
		
        //MARK: - for Sync
        let semaphore = DispatchSemaphore(value: 0)
        
        var syncData = String()
                
        var urlReq = URLRequest(url: url)
        urlReq.httpMethod = "GET"
        urlReq.timeoutInterval = TimeInterval(2)
        
        let task = URLSession.shared.dataTask(with: urlReq ) { ( returndata, _, _ ) in

            if let d = returndata {
                syncData =  String(data: d, encoding: .utf8) ?? "\(textsync_error)=1"
            } else {
                syncData = "\(textsync_error)=2"
            }
            
            //MARK: - for Sync
            semaphore.signal()
        }
        
        task.resume()
        
        //MARK: - for Sync
        _ = semaphore.wait(timeout: .distantFuture)
        
        return syncData
    }
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
