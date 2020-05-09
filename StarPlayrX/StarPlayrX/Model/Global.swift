//
//  Global.swift
//  StarPlayr
//
//  Created by Todd on 1/26/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation
import CameoKit
import UIKit

internal class Global  {
    static let obj = Global()
    
	//MARK: Constants
    let local = "127.0.0.1"
    let localhost = "localhost"
    let domain = "starplayrx.com"
    let secureport = "8180"
    let binbytes = "3369117"
    let demoname = "StarPlayrX"
    let websitedown = "403"
    let secure = "https://"
    let insecure = "http://"
    let m3u8 = ".m3u8"
    let Server = "boss"
    
    //MARK: Variables
    var demomode = true
    var imagechecksum = ""
    var Username = ""
    var Password = ""
    var lastCategory = "Init Cat"
    var categoryTitle = ""
    var currentChannel = "0"
    var lastchannel = ""
    var currentChannelName = ""
    var userid : String? = ""
    var channelList = Dictionary<String, Any>()
    var tabBarHeight = CGFloat(65.0)
    var navBarWidth = CGFloat(375.0)
    
    var PopularCategories  = Array<String>()
    var MusicCategories    = Array<String>()
    var TalkCategories     = Array<String>()
    var SportsCategories   = Array<String>()
    var MiscCategories     = Array<String>()
    
    var SelectedRow : IndexPath? = nil
    var SearchText = ""
    var ChannelData = Dictionary<String, Data>()

    internal var ChannelArray = tableData()
    
    var FilterData = tableData()
    var ColdFilteredData = tableData()
    
    typealias NowPlayingType = (channel:String,artist:String,song:String,albumArt:String,channelArt:String, image: UIImage?)
    var NowPlaying = (channel:"",artist:"",song:"",albumArt:"",channelArt:"", image: nil ) as NowPlayingType
}




typealias tableData = [(searchString:String,name:String,channel:String,title:NSMutableAttributedString,detail:NSMutableAttributedString, image:UIImage, channelImage:UIImage, albumUrl:String, largeAlbumUrl: String, largeChannelArtUrl: String, category:String, preset: Bool)]








//let gRoot = "https://player.siriusxm.com/rest/v2/experience/modules"








//Completion Handlers
typealias CompletionHandler 	= (_ success:Bool) -> Void
typealias ImageHandler 			= (_ image:UIImage?) -> Void
typealias TupleHandler 			= (_ tuple:PostReturnTuple?) -> Void
typealias DictionaryHandler 	= (_ dict:NSDictionary?) -> Void
typealias DataHandler 			= (_ data:Data?) -> Void
typealias TextHandler 			= (_ text:String?) -> Void

typealias PostReturnTuple = (message: String, success: Bool, data: NSDictionary? , response: HTTPURLResponse? )

enum PlayerState {
    case playing
    case paused
    case buffering
    case interrupted
    case stream
}
