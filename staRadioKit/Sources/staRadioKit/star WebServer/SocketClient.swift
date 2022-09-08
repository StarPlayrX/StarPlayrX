//
//  File.swift
//  
//
//  Created by Todd Bruss on 9/7/22.
//

import Foundation

extension Socket {
    public func acceptClientSocket() throws -> Socket {
        var addr = sockaddr()
        var len: socklen_t = 0
        let clientSocket = accept(self.socketFileDescriptor, &addr, &len)
        
        if clientSocket == -1 {
            throw SocketError.acceptFailed(ErrNumString.description())
        }
        
        Socket.setNoSigPipe(clientSocket)
        
        return Socket(socketFileDescriptor: clientSocket)
    }
}
