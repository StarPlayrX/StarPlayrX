//
//  PDT.swift
//  CameoKit
//
//  Created by Todd Bruss on 1/27/19.
//

import Foundation
import CryptoKit


internal func PDTendpoint() -> String {
    
    let timeInterval = Date().timeIntervalSince1970
    let convert = timeInterval * 1000 as NSNumber
    let intTime = (Int(truncating: convert))
    let time = String(intTime)
    
    let endpoint = "https://\(playerDomain)/rest/v2/experience/modules/get/discover-channel-list?type=2&batch-mode=true&format=json&request-option=discover-channel-list-withpdt&result-template=web&time=" + time
    
    return endpoint
}

//MARK: Process Artist and Song Data
internal func processPDT(data: DiscoverChannelList) -> [String:Any] {
    var ArtistSongData = [String : Any ]()
    
    //let status = data.moduleListResponse.status //100
    if let live = data.moduleListResponse?.moduleList?.modules?.first?.moduleResponse?.moduleDetails?.liveChannelResponse?.liveChannelResponses {
        
        for i in live {
            
            let channelid = i.channelID
            let markerLists = i.markerLists
            let cutlayer = markerLists?.first
            
            if let markers = cutlayer?.markers, let item = markers.first, let song = item.cut?.title, let artist = item.cut?.artists?.first?.name, let getchannelbyId = userX.ids[channelid ?? ""] as? [String: Any], let channelNo = getchannelbyId["channelNumber"] as? String {
                if let key = MD5(artist + song), let image = MemBase[key] {
                    ArtistSongData[channelNo] = ["image" : image, "artist" : artist, "song" : song]
                } else {
                    ArtistSongData[channelNo] = ["image" : "", "artist" : artist, "song" : song]
                }
            } else if let getchannelbyId = userX.ids[channelid ?? ""] as? [String: Any], let channelNo = getchannelbyId["channelNumber"] as? String {
                ArtistSongData[channelNo] = ["image" : "", "artist" : "Don't be a Slacker", "song" : "Be a Star Player. StarPlayrX"]
            }
        }
        
    } else {
        if userX.channels.count > 1 {
            for ( key, value ) in userX.channels {
                
                let v = value as! [String: Any]
                let name = v["name"] as! String
                
                //Substitute text for when channel guide is offline
                ArtistSongData[key] = ["image" : "", "artist": key, "song" : name]
            }
        } else {
            for i in 0...1000 {
                ArtistSongData["\(i)"] = ["image" : "", "artist" : "StarPlayrX", "song" : "iOS Best Sat Radio Player"]
            }
        }
    }
    return ArtistSongData
}



//MARK: New and Improved MD5
func MD5(_ d: String) -> String? {
    
    var str = String()
    
    for byte in Insecure.MD5.hash(data: d.data(using: .utf8) ?? Data() ) {
        str += String(format: "%02x", byte)
    }
    
    return str
}
