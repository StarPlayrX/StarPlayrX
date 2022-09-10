//
//  Middleware.swift
//  StarPlayrRadioApp
//
//  Created by Todd Bruss on 9/5/22.
//

import Foundation
import SwifterLite

public func startServer(_ port: UInt16) {
    let server = streamingServer()
    try? server.start(port, forceIPv4: true)
    print("Server has started on port \(port)")
}

//MARK: Swifter Embedded Web Server Routes
public func streamingServer() -> HttpServer {
    let server = HttpServer()
    
    server.get["/ping"] = { request in
        return HttpResponse.ok(.text("pong"))
    }
    
    //MARK: - US Route
    server.get["/us"] = { request in
        
        playerDomain = "player.siriusxm.com"
        root = "\(playerDomain)/rest/v2/experience/modules"
        appRegion = "US"
        
        return HttpResponse.ok(.text(appRegion))
    }
    
    //MARK: - CA Route
    server.get["/ca"] = { request in
        
        playerDomain = "player.siriusxm.ca"
        root = "\(playerDomain)/rest/v2/experience/modules"
        appRegion = "CA"
        
        return HttpResponse.ok(.text(appRegion))
    }
    
    server.post["/api/v2/autologin"]   = loginRoute()
    server.post["/api/v2/login"]       = loginRoute()
    server.post["/api/v2/session"]     = sessionRoute()
    server.post["/api/v2/channels"]    = channelsRoute()
    server.get["/pdt"]                 = pdtRoute()
    server.get["/key/1"]               = keyOneRoute()
    server.get["/playlist/:channelid"] = playlistRoute()
    server.get["/audio/:aac"]          = audioRoute(useBuffer: true)
    
    server.get["/routes"] = { request in
        print("")
        print(server.routes) //Keep this, prevents server from giving up.
        print("")
        return HttpResponse.notFound(.none) //don't return anything
    }
    
    return server
}
