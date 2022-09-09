//PlayList
import Foundation

func AudioX(data: String, channelId: String ) -> String {
        
    guard
        let hls_prime = hls_sources["Live_Primary_HLS"],
        let hls_second = hls_sources["Live_Secondary_HLS"]
        else { return "" }
    
    let bitrate : String = "256k"
        
    let rootUrl = "/AAC_Data/\(channelId)/HLS_\(channelId)_\(bitrate)_v3/"
    let hls: String
    
    usePrime ? (hls = hls_prime) : (hls = hls_second)
    
    let prefix = "\(hls)\(rootUrl)"
    let suffix = "\(userX.consumer)&token=\(userX.token)"
    let endpoint = "\(prefix)\(data)\(suffix)"
    return endpoint
}
