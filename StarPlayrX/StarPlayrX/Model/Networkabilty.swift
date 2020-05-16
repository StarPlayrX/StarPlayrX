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


public class Network {
    
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
    
    private let autoLoginQueue = DispatchQueue(label: "VoiceOverQueue", qos: .background)
    
    func LaunchServer() {
        do {
            
            //Find the first Open port
            for i in Player.shared.port..<65000 {
                if open(port: UInt16(i)) {
                    Player.shared.port = UInt16(i)
                    break
                }
            }
            
            let server = HTTPServer.Server(name: Global.obj.localhost,
                                           address: Global.obj.local,
                                           port: Int(Player.shared.port),
                                           routes: routes() )
            try HTTPServer.launch(wait: false, server)
            
        } catch {
            print(error)
        }
    }
    
    //MARK: Port Finder - This is some deep sh*t
    func open(port: in_port_t) -> (Bool) {
        
        func release(socket: Int32) {
            Darwin.shutdown(socket, SHUT_RDWR)
            close(socket)
        }
        
        let socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0)
        if socketFileDescriptor == -1 {
            return false
        }
        
        var addr = sockaddr_in()
        let sizeOfSockkAddr = MemoryLayout<sockaddr_in>.size
        addr.sin_len = __uint8_t(sizeOfSockkAddr)
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = Int(OSHostByteOrder()) == OSLittleEndian ? _OSSwapInt16(port) : port
        addr.sin_addr = in_addr(s_addr: inet_addr("0.0.0.0"))
        addr.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
        var bind_addr = sockaddr()
        memcpy(&bind_addr, &addr, Int(sizeOfSockkAddr))
        
        if Darwin.bind(socketFileDescriptor, &bind_addr, socklen_t(sizeOfSockkAddr)) == -1 {
            release(socket: socketFileDescriptor)
            return false
        }
        
        if listen(socketFileDescriptor, SOMAXCONN ) == -1 {
            release(socket: socketFileDescriptor)
            return false
        }
        
        release(socket: socketFileDescriptor)
        return true
    }

}



