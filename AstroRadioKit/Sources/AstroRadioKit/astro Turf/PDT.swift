//
//  PDT.swift
//  CameoKit
//
//  Created by Todd Bruss on 1/27/19.
//

import Foundation
import CommonCrypto

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
                if let key = sha256(artist + song), let image = MemBase[key] {
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
                
                let v = value as? [String: Any]
                guard let name = v?["name"] as? String else { return ArtistSongData}
                
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
public func sha256(_ str: String) -> String? {
    guard let data = str.data(using: .utf8) else { return nil }
    return Checksum.hash(data: data, using: .sha256)
}

struct Checksum {
    private init() {}

    static func hash(data: Data, using algorithm: HashAlgorithm) -> String {
        /// Creates an array of unsigned 8 bit integers that contains zeros equal in amount to the digest length
        var digest = [UInt8](repeating: 0, count: algorithm.digestLength())

        /// Call corresponding digest calculation
        data.withUnsafeBytes {
            guard let base = $0.baseAddress else { return }
            algorithm.digestCalculation(data: base, len: UInt32(data.count), digestArray: &digest)
        }

        var hashString = ""
        /// Unpack each byte in the digest array and add them to the hashString
        for byte in digest {
            hashString += String(format:"%02x", UInt8(byte))
        }

        return hashString
    }

    /**
    * Hash using CommonCrypto
    * API exposed from CommonCrypto-60118.50.1:
    * https://opensource.apple.com/source/CommonCrypto/CommonCrypto-60118.50.1/include/CommonDigest.h.auto.html
    **/
    enum HashAlgorithm {
        case sha256

        func digestLength() -> Int {
            switch self {
            case .sha256:
                return Int(CC_SHA256_DIGEST_LENGTH)
            }
        }

        /// CC_[HashAlgorithm] performs a digest calculation and places the result in the caller-supplied buffer for digest
        /// Calls the given closure with a pointer to the underlying unsafe bytes of the data's contiguous storage.
        func digestCalculation(data: UnsafeRawPointer, len: UInt32, digestArray: UnsafeMutablePointer<UInt8>) {
            switch self {
            case .sha256:
                CC_SHA256(data, len, digestArray)
            }
        }
    }
}
