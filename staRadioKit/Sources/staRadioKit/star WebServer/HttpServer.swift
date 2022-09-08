//
//  HttpServer.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.

//  Swifter Embedded Lite by Todd Bruss on 9/6/22.
//  Copyright © 2022 Todd Bruss. All rights reserved.

import Foundation

open class HttpServer: HttpServerIO {
    public init() {
        self.post = MethodRoute(method: "POST", router: router)
        self.get  = MethodRoute(method: "GET",  router: router)
    }
    public static let version = Bundle(for: HttpServer.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.3.1"
    
    private let router = HttpRouter()
    public var post, get: MethodRoute
    
    public subscript(path: String) -> ((HttpRequest) -> HttpResponse)? {
        get { return nil }
        set { router.register(nil, path: path, handler: newValue) }
    }
    
    public var routes: [String] {
        router.routes()
    }
        
    override open func dispatch(_ request: HttpRequest) -> ([String: String], (HttpRequest) -> HttpResponse) {
        if let result = router.route(request.method, path: request.path) {
            return result
        } else {
            return ([:], { _ in HttpResponse.notFound(nil) })
        }
    }
}
