//
//  playlistRoute.swift
//  StarPlayrRadioApp
//
//  Created by Todd Bruss on 9/5/22.
//

import Foundation
import SwifterLite

func playlistRoute() -> httpReq {{ request in
    autoreleasepool {
        var data = Data()
        
        guard
            let channelid = request.params[":channelid"]
        else {
            return HttpResponse.notFound(.none)
        }
        
        if let channel = String?(String(channelid.split(separator: ".")[0])),
           let ch = userX.channels[channel] as? NSDictionary,
           let channelid = ch["channelId"] as? String {
            
            userX.channel = channelid
            Session(channelid: channelid)
            
            let source = Playlist(channelid: channelid)
            
            TextSync(endpoint: source) { (playlist) in
                guard
                    let playlist = playlist
                else {
                    data = Data()
                    return
                }
                
                func processPlaylist(_ playlist: String) -> String {
                    var playlist = playlist
                    
                    //MARK: fix key path
                    playlist = playlist.replacingOccurrences(of: "key/1", with: "/key/1")
                    
                    //MARK: add audio prefix
                    playlist = playlist.replacingOccurrences(of: channelid, with: "/audio/" + channelid)
                    
                    //MARK: fix duration
                    playlist = playlist.replacingOccurrences(of: "#EXT-X-TARGETDURATION:10", with: "#EXT-X-TARGETDURATION:9")
                    
                    //MARK: this keeps the PDT in sync, go figure
                    playlist = playlist.replacingOccurrences(of: "#EXTINF:10,", with: "#EXTINF:1,")
                    
                    return playlist
                }

                data = processPlaylist(playlist).data(using: .utf8) ?? Data()
            }
        }
        
        if data.count > 0 {
            return HttpResponse.ok(.data(data, contentType: "application/x-mpegURL"))
        } else {
            return HttpResponse.notFound(.none)
        }
    }
}}
