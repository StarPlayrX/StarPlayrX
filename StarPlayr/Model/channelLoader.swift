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

func processChannelList()  {
    let sortedChannelList = Array(channelList!.keys).sorted {$0.localizedStandardCompare($1) == .orderedAscending}
    let tinyImageData = UIImage(named: "xplaceholder")!
    let detail = NSMutableAttributedString(string: "\n" , attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]);
    let song = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]);
    detail.append(song)
    
    var channelArray = tableData()
    
    for ch in sortedChannelList {
        
        if let blueprint = channelList![ch] as? [String : Any] {
            if let number = blueprint["channelNumber"] as? String {
                var name = blueprint["name"] as! String
                let mediumImage = blueprint["mediumImage"] as! String
                let category = blueprint["category"] as! String

                //We do not allow SiriusXM in channel names, plus it's kind of redundant
                name = name.replacingOccurrences(of: "SiriusXM", with: "Sirius")
                name = name.replacingOccurrences(of: "SXM", with: "Star")

                //remove unwanted text
                /*
                 do {
                 name = name.replacingOccurrences(of: "Kevin Hart's ", with: "")
                 name = name.replacingOccurrences(of: " Radio", with: "")
                 name = name.replacingOccurrences(of: " on SiriusXM", with: "")
                 name = name.replacingOccurrences(of: "Comedy Hits", with: "Comedy")
                 name = name.replacingOccurrences(of: " Channel", with: "")
                 name = name.replacingOccurrences(of: "Headlines 24/7", with: "24/7")
                 name = name.replacingOccurrences(of: " 100", with: "")
                 name = name.replacingOccurrences(of: " 101", with: "")
                 name = name.replacingOccurrences(of: " 54", with: "")
                 }
                 */
                
                let title = NSMutableAttributedString(string: number + " ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]);
                let channel = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]);
                
                title.append(channel)
                
                //let item = (searchString: number + name , name: name, channel: number, title: title, detail: detail, image: tinyImageData, channelImage: tinyImageData, albumUrl: "" )
                let item = (searchString: number + name , name: name, channel: number, title: title, detail: detail, image: tinyImageData, channelImage: tinyImageData, albumUrl: "", largeAlbumUrl: "", largeChannelArtUrl: mediumImage, category: category )
                channelArray.append(item)
            }
        }
    }
    
    data = channelArray

    //filterData = data
}


//Adds in Channel Art from Data Dictionary
func processChannelIcons()  {    
    if data!.count > 1 {
        for i in 1...data!.count {
            let channel = data![i - 1].channel
            if let chArt = channelData![channel] {
                let img =  UIImage(data: chArt)!
                data![i - 1].channelImage = img
                data![i - 1].image = img
            }
        }
    }

    UserDefaults.standard.set(channelList, forKey: "channelList")

}
