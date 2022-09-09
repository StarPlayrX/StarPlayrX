import Foundation

public func preflightConfig(location: String = "US") {
    
    if location == "CA" {
        playerDomain = "player.siriusxm.ca"
        root = "\(playerDomain)/rest/v2/experience/modules"
    } else {
        playerDomain = "player.siriusxm.com"
        root = "\(playerDomain)/rest/v2/experience/modules"
    }
    
    appRegion = location
    
    Config()
    
    let logindata = (email:"", pass:"", channels: [:], ids: [:], channel: "", token: "", loggedin: false, gupid: "", consumer: "", key: "", keyurl: "" ) as LoginData
    
    //AutoLogin Routine to save time
    //check for cached data
    let autoUser = UserDefaults.standard.string(forKey: "user") ?? ""
    let autoPass = UserDefaults.standard.string(forKey: "pass") ?? ""
    let autoGupid = UserDefaults.standard.string(forKey: "gupid")  ?? ""
    let autoChannels = UserDefaults.standard.dictionary(forKey: "channels") ?? Dictionary<String, Any>()
    let autoIds = UserDefaults.standard.dictionary(forKey: "ids") ?? Dictionary<String, Any>()
    
    if autoGupid != "" && autoChannels.count > 1 {
        
        let autoLoggedin = UserDefaults.standard.bool(forKey: "loggedin")
        
        let autoChannel = UserDefaults.standard.string(forKey: "channel") ?? ""
        let autoToken = UserDefaults.standard.string(forKey: "token") ?? ""
        let autoConsumer = UserDefaults.standard.string(forKey: "consumer") ?? ""
        let autoKey = UserDefaults.standard.string(forKey: "key") ?? ""
        let autoKeyurl = UserDefaults.standard.string(forKey: "keyurl") ?? ""
        
        userX = logindata
        userX.email = autoUser
        userX.channels = autoChannels
        userX.ids = autoIds
        userX.channel = autoChannel
        userX.token = autoToken
        userX.loggedin = autoLoggedin
        userX.gupid = autoGupid
        userX.consumer = autoConsumer
        userX.key = autoKey
        userX.keyurl = autoKeyurl
        userX.pass = autoPass
    }
    
    restoreCookiesX()
}

func storeCookiesX() {
    
    let cookiesStorage = HTTPCookieStorage.shared
    let userDefaults = UserDefaults.standard
    let serverBaseUrl = "https://\(root)"
    
    guard
        let url = URL(string: serverBaseUrl),
        let c = cookiesStorage.cookies(for: url)
        else { return }
    
    var cookieDict = [String : AnyObject]()
    
    for cookie in c {
        cookieDict[cookie.name] = cookie.properties as AnyObject?
    }
    
    userDefaults.set(cookieDict, forKey: "siriusxm")
}

func restoreCookiesX() {
    let cookiesStorage = HTTPCookieStorage.shared
    let userDefaults = UserDefaults.standard
    
    if let cookieDictionary = userDefaults.dictionary(forKey: "siriusxm") {
        
        for (_, cookieProperties) in cookieDictionary {
            if let cp = cookieProperties as? [HTTPCookiePropertyKey : Any],
                let cookie = HTTPCookie(properties: cp) {
                cookiesStorage.setCookie(cookie)
            }
        }
    }
}
