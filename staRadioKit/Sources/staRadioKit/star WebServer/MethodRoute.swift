//
//  File.swift
//  
//
//  Created by Todd Bruss on 9/7/22.
//

import Foundation

public struct MethodRoute {
    internal init(method: String, router: HttpRouter) {
        self.method = method
        self.router = router
    }
    
    public let method: String
    public let router: HttpRouter
    public subscript(path: String) -> ((HttpRequest) -> HttpResponse)? {
        get { nil }
        set {
            router.register(method, path: path, handler: newValue)
        }
    }
}
