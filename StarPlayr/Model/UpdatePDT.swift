//
//  UpdatePDT.swift
//  StarPlayr
//
//  Created by Todd on 3/2/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import CameoKit


public func setnowPlayingInfo(channel:String, song:String, artist:String, imageData: UIImage)
{
    let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
    let image = imageData.withBackground(color: UIColor(displayP3Red: 19 / 255, green: 20 / 255, blue: 36 / 255, alpha: 1.0))
    let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: {  (_) -> UIImage in
        return image
    })
    
    nowPlayingInfo[MPMediaItemPropertyTitle] = song
    nowPlayingInfo[MPMediaItemPropertyArtist] = artist
    nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = channel
    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
    nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
}


func updatePDT2(importData: tableData, category: String, updateScreen: Bool, updateCache: Bool) -> tableData {
    var useCacheAnyWays = false
    
    if let starplayr = player {
        if starplayr.isReady {
            useCacheAnyWays = false;
        } else {
            useCacheAnyWays = true
        }
    }
    
    var nowPlayingData = tableData() //init
    
    if category != "All" {
        nowPlayingData = importData.filter {$0.category == category}
    } else {
        nowPlayingData = importData
    }
    
    if importData.count > 0 {
        
        var pdtCache =  [String : Any]()
        
        //Caches Channel Data, so we don't have to keep fetching it all the time
        if updateCache && !useCacheAnyWays {
            let p = PDT() as! [String : Any]
            
            if p.count == 0 {
                return nowPlayingData
            }
            
            pdtCache = p["data"] as! [String : Any]
            
            if pdtCache.count == 0 {
                return nowPlayingData
            }
        
            UserDefaults.standard.set(pdtCache, forKey: "pdtCache")
            
        } else {
            pdtCache = (UserDefaults.standard.dictionary(forKey: "pdtCache")!)
        }
    
        for j in pdtCache {
            
            let key = j.key
            let value = j.value as? [String: String] ?? ["":""]
            let artistOptional : String? = value["artist"] ?? ""
            let songOptional : String? = value["song"] ?? ""
            let imageOptional : String? = value["image"] ?? ""
            var counter = 0
            
            if let artist = artistOptional, let song = songOptional, let image = imageOptional {
                
                if artist != "" {
                    for i in 0...(nowPlayingData.count - 1) {
                        
                        if nowPlayingData[i].channel == key {
                        
                            counter = counter + 1
                            
                            let setArtist = NSMutableAttributedString(string: artist + "\n" , attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]);
                            let setSong = NSMutableAttributedString(string: song, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]);
                            
                            setArtist.append(setSong)
                            
                            nowPlayingData[i].detail = setArtist
                            nowPlayingData[i].largeAlbumUrl = image
                            nowPlayingData[i].searchString = key
                            nowPlayingData[i].searchString = nowPlayingData[i].searchString + " " + data![i].name
                            nowPlayingData[i].searchString = nowPlayingData[i].searchString + " " + artist
                            nowPlayingData[i].searchString = nowPlayingData[i].searchString + " " + song
                            nowPlayingData[i].image = nowPlayingData[i].channelImage
                            nowPlayingData[i].albumUrl =  nowPlayingData[i].largeChannelArtUrl
                            
                            if key == currentChannel  {
                                
                                let get = channelList![key] as! [String:Any]
                                nowPlaying.name = get["name"] as! String
                                
                                if image != "" {
                                    
                                    nowPlayingData[i].image = nowPlayingData[i].channelImage
                                    nowPlayingData[i].albumUrl = nowPlayingData[i].largeChannelArtUrl
                                    
                                    nowPlaying.artist = artist
                                    nowPlaying.song = song
                                    nowPlaying.albumArt = image
                                    
                                   

                                    nowPlaying.channel = key
                                    nowPlaying.channelArt = nowPlayingData[i].largeChannelArtUrl
                                    
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .gotNowPlayingInfo, object: nil)
                                    }
                                    
                                } else {
                        
                                    nowPlayingData[i].image = nowPlayingData[i].channelImage
                                    nowPlayingData[i].albumUrl =  nowPlayingData[i].largeChannelArtUrl
                                    
                                    nowPlaying.artist = artist
                                    nowPlaying.song = song
                                    nowPlaying.albumArt = nowPlayingData[i].largeChannelArtUrl
                                    nowPlaying.channel = key
                                    nowPlaying.channelArt = nowPlayingData[i].largeChannelArtUrl
                                    
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .gotNowPlayingInfo, object: nil)
                                    }
                                }
                                
                                break
                            }
                        }
                    }
                }
            }
            
            //If we complete our missing break
            if counter > nowPlayingData.count + 1 {
                break
            }
        }
    }
    
    return nowPlayingData
}

extension UIImage {
    func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return self }
        defer { UIGraphicsEndImageContext() }
        
        let rect = CGRect(origin: .zero, size: size)
        ctx.setFillColor(color.cgColor)
        ctx.fill(rect)
        ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
        ctx.draw(cgImage!, in: rect)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    //let size = image.size
    let rect = CGRect(x: 0, y: 0, width: 80, height: 80)
    
    UIGraphicsBeginImageContextWithOptions( targetSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}
