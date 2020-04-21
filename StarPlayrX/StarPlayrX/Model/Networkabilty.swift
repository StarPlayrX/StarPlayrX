//
//  Networkabilty.swift
//  StarPlayr
//
//  Created by Todd on 5/2/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Network
let monitor = NWPathMonitor()
var networkIsConnected = Bool()
var networkIsWiFi = Bool()
var networkIsTripped = false

public class Networkability {
    
    func start() {
        
        monitor.pathUpdateHandler = { path in
            
            networkIsConnected = (path.status == .satisfied)
            
            if !networkIsConnected {
                networkIsTripped = true
            }
        
            networkIsWiFi = path.usesInterfaceType(.wifi)
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}



