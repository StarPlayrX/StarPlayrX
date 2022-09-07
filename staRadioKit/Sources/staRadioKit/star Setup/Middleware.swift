//
//  Middleware.swift
//  StarPlayrRadioApp
//
//  Created by Todd Bruss on 9/5/22.
//

import Foundation
//import AppKit

public func startServer(_ port: UInt16) {
    let server = streamingServer()
    try? server.start(port, forceIPv4: true)
    print("Server has started...\n\n")
}

public func streamingServer() -> HttpServer {
    
    let server = HttpServer()
    
    autoreleasepool {
        server["/ping"] = { request in
            return HttpResponse.ok(.text("pong"))
        }
    }
    
    //MARK: - US Route
    autoreleasepool {
        server["/us"] = { request in
            
            playerDomain = "player.siriusxm.com"
            root = "\(playerDomain)/rest/v2/experience/modules"
            appRegion = "US"
            
            return HttpResponse.ok(.text(appRegion))
        }
    }
    
    //MARK: - CA Route
    autoreleasepool {
        server["/ca"] = { request in
            
            playerDomain = "player.siriusxm.ca"
            root = "\(playerDomain)/rest/v2/experience/modules"
            appRegion = "CA"
            
            return HttpResponse.ok(.text(appRegion))
        }
    }
    
    //MARK: Swifter Embedded Web Server Routes
    
    //MARK: - POST Login Route
    autoreleasepool {
        server.post["/api/v2/autologin"] = loginRoute()
        server.post["/api/v2/login"]     = loginRoute()
    }
    
    //MARK: - POST Session Route
    autoreleasepool {
        server.post["/api/v2/session"] = sessionRoute()
    }
    
    autoreleasepool {
        server.post["/api/v2/channels"] = channelsRoute()
    }
    
    autoreleasepool {
        server.get["/pdt"] = pdtRoute()
    }
    
    autoreleasepool {
        server.get["/key/1"] = keyOneRoute()
    }
    
    autoreleasepool {
        server.get["/playlist/:channelid"] = playlistRoute()
    }
    
    autoreleasepool {
        server.get["/audio/:aac"] = audioRoute()
    }
    
    autoreleasepool {
        server["/routes"] = { request in
            print("")
            print(server.routes) //Keep this, prevents server from giving up.
            print("")
            return HttpResponse.ok(.text("")) //don't return anything
        }
    }
    
    return server
}
