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

typealias nowPlayingType = (name:String,channel:String,artist:String,song:String,albumArt:String,channelArt:String)
typealias tableData = [(searchString:String,name:String,channel:String,title:NSMutableAttributedString,detail:NSMutableAttributedString, image:UIImage, channelImage:UIImage, albumUrl:String, largeAlbumUrl: String, largeChannelArtUrl: String, category:String)]

var nowPlaying = (name:"",channel:"",artist:"",song:"",albumArt:"",channelArt:"") as nowPlayingType
var data : tableData? = nil
var filterData = tableData()
var coldFilteredData = tableData()

var currentChannel = "0"
var volume = Float(1.0)
var userid : String? = ""
var loginSuccess : Bool? = false
var channelList : Dictionary<String, Any>? = nil
var channelData : Dictionary<String, Data>? = nil
var XLchannelData : Dictionary<String, Data>? = nil

var iconsAreLoaded = false

var categoryTitle = ""

var MusicCategories = Array<String>()
var TalkCategories = Array<String>()
var SportsCategories = Array<String>()
var MiscCategories = Array<String>()

var gUsername = ""
var gPassword = ""
var gUserid = ""

//let gRoot = "https://player.siriusxm.com/rest/v2/experience/modules"
let auth = "/modify/authentication"
let local = "127.0.0.1"
let localhost = "localhost"
let domain = "starplayrx.com"
let secureport = "8180"
let secureport2 = "8182"

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
