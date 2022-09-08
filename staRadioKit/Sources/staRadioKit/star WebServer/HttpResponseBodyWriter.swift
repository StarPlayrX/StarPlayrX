//
//  File.swift
//  
//
//  Created by Todd Bruss on 9/7/22.
//

import Foundation

public enum SerializationError: Error {
    case invalidObject
    case notSupported
}

public protocol HttpResponseBodyWriter {
    func write(data s: Data) throws
    func write(bytes: [UInt8]) throws
}
