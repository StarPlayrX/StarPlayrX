//
//  Networkabilty.swift
//  StarPlayr
//
//  Created by Todd on 5/2/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Network
import Foundation
import CameoKit
import PerfectHTTPServer
import PerfectHTTP
import AVKit

public class Networkability {
    
    static var shared = Networkability()
    
    let monitor = NWPathMonitor()
    var networkIsConnected = Bool()
    var networkIsWiFi = Bool()
    var networkIsTripped = false
    
    func start() {
        
        self.monitor.pathUpdateHandler = { path in
            
            self.networkIsConnected = (path.status == .satisfied)
            
            if !self.networkIsConnected {
                self.networkIsTripped = true
            }
        
            self.networkIsWiFi = path.usesInterfaceType(.wifi)
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    private let autoLoginQueue = DispatchQueue(label: "VoiceOverQueue", qos: .background)
    
    func LaunchServer() {
        do {
            //Find the first Open port
            for i in Player.shared.port...64999 {
                let (isFree, _) = checkTcpPortForListen(port: UInt16(i))
                if isFree {
                    Player.shared.port = UInt16(i)
                    break;
                }
            }
            
            let server = HTTPServer.Server(name: Global.obj.localhost, address: Global.obj.local, port: Int(Player.shared.port), routes: routes() )
            try HTTPServer.launch(wait: false, server)
            
        } catch {
            print(error)
        }
    }
}



