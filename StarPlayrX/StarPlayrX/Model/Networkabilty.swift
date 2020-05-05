//
//  Networkabilty.swift
//  StarPlayr
//
//  Created by Todd on 5/2/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Network


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
}



