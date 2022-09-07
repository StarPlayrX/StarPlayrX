//
//  MimeTypes.swift
//  Swifter
//
//  Created by Daniel Große on 16.02.18.

//  Swifter Embedded Lite by Todd Bruss on 9/6/22.
//  Copyright © 2022 Todd Bruss. All rights reserved.

import Foundation

internal let DEFAULT_MIME_TYPE = "audio/aac"

internal let mimeTypes = [
    "m3u8": "application/x-mpegURL",
    "aac" : "audio/aac",
    "txt" : "text/plain",
    "json": "application/json",
]

internal func matchMimeType(extens: String?) -> String {
    if extens != nil && mimeTypes.contains(where: { $0.0 == extens!.lowercased() }) {
        return mimeTypes[extens!.lowercased()]!
    }
    return DEFAULT_MIME_TYPE
}

extension NSURL {
    public func mimeType() -> String {
        return matchMimeType(extens: self.pathExtension)
    }
}

extension NSString {
    public func mimeType() -> String {
        return matchMimeType(extens: self.pathExtension)
    }
}

extension String {
    public func mimeType() -> String {
        return (NSString(string: self)).mimeType()
    }
}

//internal let mimeTypes = [
//    "aac" : "audio/aac",
//    "txt" : "text/plain",
//    "webp": "image/webp",
//    "json": "application/json",
//    "m3u8": "application/x-mpegURL",
//    "der" : "application/x-x509-ca-cert",
//    "pem" : "application/x-x509-ca-cert",
//    "crt" : "application/x-x509-ca-cert",
//    "midi": "audio/midi",
//    "mp3" : "audio/mpeg",
//    "ogg" : "audio/ogg",
//    "m4a" : "audio/x-m4a",
//    "ra"  : "audio/x-realaudio",
//    "3gp" : "video/3gpp",
//    "ts"  : "video/mp2t",
//    "mp4" : "video/mp4",
//    "mpeg": "video/mpeg",
//    "mpg" : "video/mpeg",
//    "mov" : "video/quicktime",
//    "webm": "video/webm",
//    "m4v" : "video/x-m4v",
//    "wmv" : "video/x-ms-wmv",
//    "avi" : "video/x-msvideo"
//]
