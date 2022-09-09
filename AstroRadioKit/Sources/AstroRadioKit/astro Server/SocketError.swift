//
//  File.swift
//  
//
//  Created by Todd Bruss on 9/8/22.
//

import Foundation

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
