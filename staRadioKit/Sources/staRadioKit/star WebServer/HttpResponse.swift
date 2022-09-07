//
//  HttpResponse.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.

//  Swifter Embedded Lite by Todd Bruss on 9/6/22.
//  Copyright © 2022 Todd Bruss. All rights reserved.

import Foundation

public enum SerializationError: Error {
    case invalidObject
    case notSupported
}

public protocol HttpResponseBodyWriter {
    func write(_ data: Data) throws
    func write(_ data: [UInt8]) throws
}

public enum HttpResponseBody {
    
    case json(Any)
    case text(String)
    case data(Data, contentType: String? = nil)
    case custom(Any, (Any) throws -> String)
    
    func content() -> (Int, ((HttpResponseBodyWriter) throws -> Void)?) {
        do {
            switch self {
            case .json(let object):
                guard JSONSerialization.isValidJSONObject(object) else {
                    throw SerializationError.invalidObject
                }
                let data = try JSONSerialization.data(withJSONObject: object)
                return (data.count, {
                    try $0.write(data)
                })
            case .text(let body):
                let data = [UInt8](body.utf8)
                return (data.count, {
                    try $0.write(data)
                })
                
            case .data(let data, _):
                return (data.count, {
                    try $0.write(data)
                })
            case .custom(let object, let closure):
                let serialized = try closure(object)
                let data = [UInt8](serialized.utf8)
                return (data.count, {
                    try $0.write(data)
                })
            }
        } catch {
            let data = [UInt8]("Serialization error: \(error)".utf8)
            return (data.count, {
                try $0.write(data)
            })
        }
    }
}

public enum HttpResponse {
    
    case switchProtocols([String: String], (Socket) -> Void)
    case ok(HttpResponseBody, [String: String] = [:]), created, accepted
    case notFound(HttpResponseBody? = nil)
    case raw(Int, String, [String: String]?, ((HttpResponseBodyWriter) throws -> Void)? )
    
    public var statusCode: Int {
        switch self {
        case .switchProtocols         : return 101
        case .ok                      : return 200
        case .created                 : return 201
        case .accepted                : return 202
        case .notFound                : return 404
        case .raw(let code, _, _, _)  : return code
        }
    }
    
    public var reasonPhrase: String {
        switch self {
        case .switchProtocols          : return "Switching Protocols"
        case .ok                       : return "OK"
        case .created                  : return "Created"
        case .accepted                 : return "Accepted"
        case .notFound                 : return "Not Found"
        case .raw(_, let phrase, _, _) : return phrase
        }
    }
    
    public func headers() -> [String: String] {
        var headers = ["Server": "Swifter \(HttpServer.version)"]
        switch self {
        case .switchProtocols(let switchHeaders, _):
            for (key, value) in switchHeaders {
                headers[key] = value
            }
        case .ok(let body, let customHeaders):
            for (key, value) in customHeaders {
                headers.updateValue(value, forKey: key)
            }
            switch body {
            case .json: headers["Content-Type"] = "application/json"
            case .text: headers["Content-Type"] = "text/plain"
            case .data(_, let contentType): headers["Content-Type"] = contentType
            default:break
            }
        case .raw(_, _, let rawHeaders, _):
            if let rawHeaders = rawHeaders {
                for (key, value) in rawHeaders {
                    headers.updateValue(value, forKey: key)
                }
            }
        default:break
        }
        return headers
    }
    
    func content() -> (length: Int, write: ((HttpResponseBodyWriter) throws -> Void)?) {
        switch self {
        case .ok(let body, _)          : return body.content()
        case .notFound(let body)       : return body?.content() ?? (-1, nil)
        case .raw(_, _, _, let writer) : return (-1, writer)
        default                        : return (-1, nil)
        }
    }
    
    func socketSession() -> ((Socket) -> Void)? {
        switch self {
        case .switchProtocols(_, let handler) : return handler
        default: return nil
        }
    }
}

//func == (inLeft: HttpResponse, inRight: HttpResponse) -> Bool {
//    inLeft.statusCode == inRight.statusCode
//}
