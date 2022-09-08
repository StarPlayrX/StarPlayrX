//
//  Socket.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.

//  Swifter Embedded Lite by Todd Bruss on 9/6/22.
//  Copyright © 2022 Todd Bruss. All rights reserved.

import Foundation

open class Socket: Hashable, Equatable {
    
    let socketFileDescriptor: Int32
    private var shutdown = false
    
    public init(socketFileDescriptor: Int32) {
        self.socketFileDescriptor = socketFileDescriptor
    }
    
    deinit {
        close()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.socketFileDescriptor)
    }
    
    public func close() {
        if shutdown {
            return
        } else {
            shutdown = true
            Socket.close(self.socketFileDescriptor)
        }
    }

    /// Read a single byte off the socket. This method is optimized for reading
    /// a single byte. For reading multiple bytes, use read(length:), which will
    /// pre-allocate heap space and read directly into it.
    ///
    /// - Returns: A single byte
    /// - Throws: SocketError.recvFailed if unable to read from the socket
    open func read() throws -> UInt8 {
        var byte: UInt8 = 0
        
        let count = Darwin.read(self.socketFileDescriptor as Int32, &byte, 1)
        
        guard count > 0 else {
            throw SocketError.recvFailed(ErrNumString.description())
        }
        return byte
    }
    
    /// Read up to `length` bytes from this socket
    ///
    /// - Parameter length: The maximum bytes to read
    /// - Returns: A buffer containing the bytes read
    /// - Throws: SocketError.recvFailed if unable to read bytes from the socket
    open func read(length: Int) throws -> [UInt8] {
        return try [UInt8](unsafeUninitializedCapacity: length) { buffer, bytesRead in
            bytesRead = try read(into: &buffer, length: length)
        }
    }
    
    static let kBufferLength = 1024
    
    /// Read up to `length` bytes from this socket into an existing buffer
    ///
    /// - Parameter into: The buffer to read into (must be at least length bytes in size)
    /// - Parameter length: The maximum bytes to read
    /// - Returns: The number of bytes read
    /// - Throws: SocketError.recvFailed if unable to read bytes from the socket
    func read(into buffer: inout UnsafeMutableBufferPointer<UInt8>, length: Int) throws -> Int {
        var offset = 0
        guard let baseAddress = buffer.baseAddress else { return 0 }
        
        while offset < length {
            // Compute next read length in bytes. The bytes read is never more than kBufferLength at once.
            let readLength = offset + Socket.kBufferLength < length ? Socket.kBufferLength : length - offset
            let bytesRead = Darwin.read(self.socketFileDescriptor as Int32, baseAddress + offset, readLength)
            
            guard bytesRead > 0 else {
                throw SocketError.recvFailed(ErrNumString.description())
            }
            
            offset += bytesRead
        }
        
        return offset
    }
    
    private static let CR: UInt8 = 13
    private static let NL: UInt8 = 10
    
    public func readLine() throws -> String {
        var characters: String = ""
        var index: UInt8 = 0
        
        repeat {
            index = try self.read()
            if index > Socket.CR { characters.append(Character(UnicodeScalar(index))) }
        } while index != Socket.NL
        
        return characters
    }
    
    public func peername() throws -> String {
        var addr = sockaddr(), len: socklen_t = socklen_t(MemoryLayout<sockaddr>.size)
        if getpeername(self.socketFileDescriptor, &addr, &len) != 0 {
            throw SocketError.getPeerNameFailed(ErrNumString.description())
        }
        var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        if getnameinfo(&addr, len, &hostBuffer, socklen_t(hostBuffer.count), nil, 0, NI_NUMERICHOST) != 0 {
            throw SocketError.getNameInfoFailed(ErrNumString.description())
        }
        return String(cString: hostBuffer)
    }
    
    public class func setNoSigPipe(_ socket: Int32) {
        // Prevents crashes when blocking calls are pending and the app is paused ( via Home button ).
        var no_sig_pipe: Int32 = 1
        setsockopt(socket, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, socklen_t(MemoryLayout<Int32>.size))
    }
    
    public class func close(_ socket: Int32) {
        _ = Darwin.close(socket)
    }
}

public func == (socket1: Socket, socket2: Socket) -> Bool {
    socket1.socketFileDescriptor == socket2.socketFileDescriptor
}

public enum SocketError: Error {
    case socketCreationFailed(String)
    case socketSettingReUseAddrFailed(String)
    case bindFailed(String)
    case listenFailed(String)
    case writeFailed(String)
    case getPeerNameFailed(String)
    case convertingPeerNameFailed
    case getNameInfoFailed(String)
    case acceptFailed(String)
    case recvFailed(String)
    case getSockNameFailed(String)
}

public class ErrNumString {
    public class func description() -> String {
        "\(String(describing: strerror(errno)))"
    }
}
