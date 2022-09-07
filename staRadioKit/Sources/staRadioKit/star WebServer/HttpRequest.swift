//
//  HttpRequest.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.

//  Swifter Embedded Lite by Todd Bruss on 9/6/22.
//  Copyright © 2022 Todd Bruss. All rights reserved.


import Foundation

public class HttpRequest {
    
    public var path: String
    public var queryParams: [(String, String)]
    public var method: String
    public var headers: [String: String]
    public var body: [UInt8]
    public var address: String?
    public var params: [String: String]
    
    internal init
    (
        path: String = "",
        queryParams: [(String, String)] = [("","")],
        method: String = "",
        headers: [String : String] = [:],
        body: [UInt8] = [],
        address: String? = nil,
        params: [String : String] = [:]
    ) {
        self.path = path
        self.queryParams = queryParams
        self.method = method
        self.headers = headers
        self.body = body
        self.address = address
        self.params = params
    }
}
