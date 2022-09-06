
//
//  Playlist makek
//
//  Created by Todd on 1/16/19.
//

import Foundation

//Cached verison of Playlist
func Playlist(channelid: String) -> String {
    let bitrate = "256k"
    
//    let net = Network.ability
//
//    //Get Network Info, so we know what to do with the stream
//    if ( net.networkIsWiFi && net.networkIsConnected ) {
//        bitrate = "256k"
//    } else if ( !net.networkIsWiFi && net.networkIsConnected ) {
//        bitrate = "64k"
//    } else {
//        bitrate = "32k"
//    }
    
    let size = "medium"
    let underscore = "_"
    let version = "v3"
    let ext = ".m3u8"
    
    let tail = channelid + underscore + bitrate + underscore + size + underscore + version + ext
    var source = userX.keyurl
    
    let primary = String(hls_sources["Live_Primary_HLS"] ?? "")
    let secondary = String(hls_sources["Live_Secondary_HLS"] ?? "")
    
    if usePrime {
        source = source.replacingOccurrences(of: "%Live_Primary_HLS%", with: primary)
    } else {
        source = source.replacingOccurrences(of: "%Live_Primary_HLS%", with: secondary)
    }
    
    source = source.replacingOccurrences(of: "32k",  with: bitrate)
    source = source.replacingOccurrences(of: "key/1", with: tail)
    source = source + userX.consumer + "&token=" + userX.token
        
	return source
}
