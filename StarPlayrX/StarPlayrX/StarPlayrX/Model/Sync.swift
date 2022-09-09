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
        try? NSData(contentsOfFile: Bundle.main.path(forResource: filename, ofType: "dms") ?? "") as Data
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
