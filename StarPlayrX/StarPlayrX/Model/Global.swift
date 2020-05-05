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

typealias nowPlayingType = (channel:String,artist:String,song:String,albumArt:String,channelArt:String, image: UIImage?)
typealias tableData = [(searchString:String,name:String,channel:String,title:NSMutableAttributedString,detail:NSMutableAttributedString, image:UIImage, channelImage:UIImage, albumUrl:String, largeAlbumUrl: String, largeChannelArtUrl: String, category:String, preset: Bool)]

var nowPlaying = (channel:"",artist:"",song:"",albumArt:"",channelArt:"", image: nil ) as nowPlayingType
var filterData = tableData()
var coldFilteredData = tableData()

var currentChannel = "0"
var volume = Float(1.0)
var userid : String? = ""
var loginSuccess : Bool? = false
var channelList = Dictionary<String, Any>()
var channelData = Dictionary<String, Data>()
var XLchannelData = Dictionary<String, Data>()

var iconsAreLoaded = false

var categoryTitle = ""

var PopularCategories 	= Array<String>()
var MusicCategories 	= Array<String>()
var TalkCategories 		= Array<String>()
var SportsCategories 	= Array<String>()
var MiscCategories 		= Array<String>()

var gUsername = ""
var gPassword = ""
var gUserid = ""

//let gRoot = "https://player.siriusxm.com/rest/v2/experience/modules"
let auth = "/modify/authentication"
let local = "127.0.0.1"
let localhost = "localhost"
let domain = "starplayrx.com"
let secureport = "8180"
let secureport2 = "8180"
let binbytes = "3369117"
let demoname = "StarPlayrX"
var demomode = true
let websitedown = "403"
let secure = "https://"
let insecure = "http://"
let m3u8 = ".m3u8"
let slashGet = "/get"
let gAkamai = "https://siriusxm-priprodlive.akamaized.net"
var gChannels = Dictionary<String, Any>()
var gStream = ""
var gGupid = "D903EFA651C741B3356C26BE514AC017"
var gConsumer = "?consumer=k2&gupId=D903EFA651C741B3356C26BE514AC017"
var gToken = "init" //may go with a local one because it changes all the time
var gChannelId = ""
var gLoggedinUser = ""
var gLogin = false
var gChain = false
var gCookies = false
var gLava = false
var gUser = Dictionary<String, (pass:String, channel: String, token: String, loggedin: Bool, guid: String, gupid: String, consumer: String)>()

var tabBarHeight = CGFloat(65.0)
var navBarWidth = CGFloat(375.0)

var lastchannel = ""
var currentChannelName = ""
var selectedRow : IndexPath? = nil
var lastCategory = "Init Cat"
var globalSearchText = ""

//Completion Handlers
typealias CompletionHandler = (_ success:Bool) -> Void
typealias ImageHandler = (_ image:UIImage?) -> Void
typealias DictionaryHandler = (_ dict:NSDictionary?) -> Void
typealias TextHandler = (_ text:String?) -> Void

enum PlayerState {
    case playing
    case paused
    case buffering
    case interrupted
    case stream
}
