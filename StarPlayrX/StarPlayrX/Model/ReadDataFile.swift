//
//  readLocalDataFile.swift
//  StarPlayrX
//
//  Created by Todd Bruss on 7/29/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation

func readLocalDataFile(filename:String) -> Data?  {
    let dms = Bundle.main.path(forResource: filename, ofType: "dms")
    
    if let artwork = dms {
        if let data = NSData(contentsOfFile: artwork) {
            return data as Data
        } else {
            return nil
        }
    }
    
    return nil
}

