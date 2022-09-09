//
//  File.swift
//  
//
//  Created by Todd Bruss on 9/7/22.
//

import Foundation

extension Socket {
    public func port() throws -> in_port_t {
        var addr = sockaddr_in()
        return try withUnsafePointer(to: &addr) { pointer in
            var len = socklen_t(MemoryLayout<sockaddr_in>.size)
            if getsockname(socketFileDescriptor, UnsafeMutablePointer(OpaquePointer(pointer)), &len) != 0 {
                throw SocketError.getSockNameFailed(ErrNumString.description())
            }
            let sin_port = pointer.pointee.sin_port
            return Int(OSHostByteOrder()) != OSLittleEndian ? sin_port.littleEndian : sin_port.bigEndian
        }
    }
    
    public func isIPv4() throws -> Bool {
        var addr = sockaddr_in()
        return try withUnsafePointer(to: &addr) { pointer in
            var len = socklen_t(MemoryLayout<sockaddr_in>.size)
            if getsockname(socketFileDescriptor, UnsafeMutablePointer(OpaquePointer(pointer)), &len) != 0 {
                throw SocketError.getSockNameFailed(ErrNumString.description())
            }
            return Int32(pointer.pointee.sin_family) == AF_INET
        }
    }
}
