//
//  channelLoader.swift
//  StarPlayr
//
//  Created by Todd on 2/10/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer

internal var channelArray = tableData()

func processChannelList()  {
    channelArray = tableData()
    
    let sortedChannelList = Array(channelList.keys).sorted {$0.localizedStandardCompare($1) == .orderedAscending}
    let detail = NSMutableAttributedString(string: "\n" , attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]);
    let song = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]);
    detail.append(song)
    
    for ch in sortedChannelList {
        
        if let blueprint = channelList[ch] as? [String : Any],
            let number = blueprint["channelNumber"] as? String,
            var name = blueprint["name"] as? String,
            let mediumImage = blueprint["mediumImage"] as? String,
            let category = blueprint["category"] as? String,
            let preset = blueprint["preset"] as? Bool,
            let tinyImageData = UIImage(named: "xplaceholder") {
            
            //We do not allow SiriusXM in channel names, plus it's kind of redundant
        	name = name.replacingOccurrences(of: "SiriusXM", with: "Sirius")
            name = name.replacingOccurrences(of: "SXM", with: "SPX")
            
            let title = NSMutableAttributedString(string: number + " ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)])
            let channel = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)])
            
            title.append(channel)
            
            let item = (searchString: number + name , name: name, channel: number, title: title, detail: detail, image: tinyImageData, channelImage: tinyImageData, albumUrl: "", largeAlbumUrl: "", largeChannelArtUrl: mediumImage, category: category, preset: preset )
            channelArray.append(item)
        }
    }
    
    let ps = Player.shared
    
    //Read in the presets
    let x = (UserDefaults.standard.array(forKey: "SPXPresets") ?? ["2","3","4"]) as [String]
    
        ps.SPXPresets = x
        if !ps.SPXPresets.isEmpty && !channelArray.isEmpty {
            var c = -1
            for t in channelArray {
                c += 1
                
                for p in ps.SPXPresets {
                    if p == t.channel {
                        channelArray[c].preset = true
                        break
                    }
                }
            }
        }
}



//Adds in Channel Art from Data Dictionary
func processChannelIcons()  {
    if !channelArray.isEmpty && !channelData.isEmpty {
        for i in 0...channelArray.count - 1 {
            let channel = channelArray[i].channel
            if let chArt = channelData[channel], let img = UIImage(data: chArt) {
                channelArray[i].channelImage = img
                channelArray[i].image = img
            }
        }
    }
    
   // UserDefaults.standard.set(channelList, forKey: "channelList")
}
