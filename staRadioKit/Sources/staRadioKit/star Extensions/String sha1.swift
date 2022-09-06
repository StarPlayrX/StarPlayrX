//
//  String+SHA1.swift
//  Swifter
//
//  Copyright 2014-2016 Damian Kołakowski. All rights reserved.
//

import Foundation
import CryptoKit

extension String {
    public func sha1() -> [UInt8] {
        Insecure.SHA1.hash(data: [UInt8](self.utf8)).toBytes
    }
}

extension Digest {
    var toBytes: [UInt8] { Array(makeIterator()) }
    var toData: Data { Data(toBytes) }
    var toHex: String {
        toBytes.map { String(format: "%02x", $0) }.joined().uppercased()
    }
}
