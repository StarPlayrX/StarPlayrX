//
//  HttpRouter.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.

//  Swifter Embedded Lite by Todd Bruss on 9/6/22.
//  Copyright © 2022 Todd Bruss. All rights reserved.

import Foundation

open class HttpRouter {
    internal init(rootNode: HttpRouter.Node = Node()) {
        self.rootNode = rootNode
    }

    internal class Node {
        /// The children nodes that form the route
        var nodes = [String: Node]()
        
        /// Define whether or not this node is the end of a route
        var isEndOfRoute: Bool = false
        
        /// The closure to handle the route
        var handler: ((HttpRequest) -> HttpResponse)?
    }
    
    private var rootNode = Node()
        private let queue = DispatchQueue(label: "swifter.embedded.lite.queue")
    
    public func routes() -> [String] {
        var routes = [String]()
        for (_, child) in rootNode.nodes {
            routes.append(contentsOf: routesForNode(child))
        }
        return routes
    }
    
    private func routesForNode(_ node: Node, prefix: String = "") -> [String] {
        var result = [String]()
        if node.handler != nil {
            result.append(prefix)
        }
        for (key, child) in node.nodes {
            result.append(contentsOf: routesForNode(child, prefix: prefix + "/" + key))
        }
        return result
    }
    
    public func register(_ method: String?, path: String, handler: ((HttpRequest) -> HttpResponse)?) {
        var pathSegments = stripQuery(path).split("/")
        if let method = method {
            pathSegments.insert(method, at: 0)
        } else {
            pathSegments.insert("*", at: 0)
        }
        var pathSegmentsGenerator = pathSegments.makeIterator()
        inflate(&rootNode, generator: &pathSegmentsGenerator).handler = handler
    }
    
    public func route(_ method: String?, path: String) -> ([String: String], (HttpRequest) -> HttpResponse)? {
        //FixMe - test async
        return queue.sync {
            if let method = method {
                let pathSegments = (method + "/" + stripQuery(path)).split("/")
                var pathSegmentsGenerator = pathSegments.makeIterator()
                var params = [String: String]()
                if let handler = findHandler(&rootNode, params: &params, generator: &pathSegmentsGenerator) {
                    return (params, handler)
                }
            }
            
            let pathSegments = ("*/" + stripQuery(path)).split("/")
            var pathSegmentsGenerator = pathSegments.makeIterator()
            var params = [String: String]()
            if let handler = findHandler(&rootNode, params: &params, generator: &pathSegmentsGenerator) {
                return (params, handler)
            }
            
            return nil
        }
    }
    
    private func inflate(_ node: inout Node, generator: inout IndexingIterator<[String]>) -> Node {
        var currentNode = node
        
        while let pathSegment = generator.next() {
            if let nextNode = currentNode.nodes[pathSegment] {
                currentNode = nextNode
            } else {
                currentNode.nodes[pathSegment] = Node()
                currentNode = currentNode.nodes[pathSegment]!
            }
        }
        
        currentNode.isEndOfRoute = true
        return currentNode
    }
    
    private func findHandler(_ node: inout Node, params: inout [String: String], generator: inout IndexingIterator<[String]>) -> ((HttpRequest) -> HttpResponse)? {
        var matchedRoutes = [Node]()
        let pattern = generator.map { $0 }
        let numberOfElements = pattern.count
        
        findHandler(&node, params: &params, pattern: pattern, matchedNodes: &matchedRoutes, index: 0, count: numberOfElements)
        return matchedRoutes.first?.handler
    }
    
    /// Find the handlers for a specified route
    ///
    /// - Parameters:
    ///   - node: The root node of the tree representing all the routes
    ///   - params: The parameters of the match
    ///   - pattern: The pattern or route to find in the routes tree
    ///   - matchedNodes: An array with the nodes matching the route
    ///   - index: The index of current position in the generator
    ///   - count: The number of elements if the route to match
    private func findHandler(_ node: inout Node, params: inout [String: String], pattern: [String], matchedNodes: inout [Node], index: Int, count: Int) {
        
        if index < count, let pathToken = pattern[index].removingPercentEncoding {
            let currentIndex = index + 1
            let variableNodes = node.nodes.filter { $0.0.first == ":" }
            
            if let variableNode = variableNodes.first, currentIndex == count && variableNode.1.isEndOfRoute {
                let tail = pattern[currentIndex..<count].joined(separator: "/")
                params[variableNode.0] = tail.count > 0 ? pathToken + "/" + tail : pathToken
                matchedNodes.append(variableNode.value)
            } else if var node = node.nodes[pathToken] {
                findHandler(&node, params: &params, pattern: pattern, matchedNodes: &matchedNodes, index: currentIndex, count: count)
            }
        } else if node.isEndOfRoute && index == count {
            matchedNodes.append(node)
        }
        
    }
    
    private func stripQuery(_ path: String) -> String {
        if let stripped = path.components(separatedBy: "?").first {
            return stripped
        }
        return path
    }
}

extension String {
    func split(_ separator: Character) -> [String] {
        return self.split { $0 == separator }.map(String.init)
    }
}
