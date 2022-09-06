//
//  Networkability.swift
//  CameoKit
//
//  Created by Todd Bruss on 5/4/19.
//

import Network

internal class Network {
    
    static var ability = Network()
    
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
