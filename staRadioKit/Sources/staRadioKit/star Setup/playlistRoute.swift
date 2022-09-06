//
//  playlistRoute.swift
//  StarPlayrRadioApp
//
//  Created by Todd Bruss on 9/5/22.
//

import Foundation

func playlistRoute() -> ((HttpRequest) -> HttpResponse) {
    return { request in
        
        autoreleasepool {
            var data = Data()
            
            guard
                let channelid = request.params[":channelid"]
            else {
                return HttpResponse.ok(.data(Data(), contentType: ""))
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
                        data = "An Error Occurred.\n\r".data(using: .utf8) ?? Data()
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
            } else {
                data = "The channel does not exist.\n\r".data(using: .utf8) ?? Data()
            }
            
            return HttpResponse.ok(.data(data, contentType: "application/x-mpegURL"))
        }
    }
}
