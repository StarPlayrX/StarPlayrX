//
//  nowPlaying.swift
//  StarPlayr
//
//  Created by Todd on 2/10/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation
import CameoKit

public func PDT() -> NSDictionary {
    
    let endpoint = insecure + local + ":" + String(port) + "/pdt/"  + userid!
    let method = "pdt"
    
    let artistSongData = GetSync(endpoint: endpoint, method: method )

    return artistSongData
  
}


