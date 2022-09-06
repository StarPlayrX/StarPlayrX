//
//  MimeTypes.swift
//  Swifter
//
//  Created by Daniel Große on 16.02.18.
//

import Foundation

internal let DEFAULT_MIME_TYPE = "audio/acc"

internal let mimeTypes = [
    "acc": "audio/acc",
    "html": "text/html",
    "htm": "text/html",
    "shtml": "text/html",
    "css": "text/css",
    "txt": "text/plain",
    "webp": "image/webp",
    "json": "application/json",
    "m3u8": "application/x-mpegURL",
    "der": "application/x-x509-ca-cert",
    "pem": "application/x-x509-ca-cert",
    "crt": "application/x-x509-ca-cert",
    "midi": "audio/midi",
    "mp3": "audio/mpeg",
    "ogg": "audio/ogg",
    "m4a": "audio/x-m4a",
    "ra": "audio/x-realaudio",
    "3gp": "video/3gpp",
    "ts": "video/mp2t",
    "mp4": "video/mp4",
    "mpeg": "video/mpeg",
    "mpg": "video/mpeg",
    "mov": "video/quicktime",
    "webm": "video/webm",
    "flv": "video/x-flv",
    "m4v": "video/x-m4v",
    "wmv": "video/x-ms-wmv",
    "avi": "video/x-msvideo"
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
