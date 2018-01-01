//
//  Router.swift
//  SweetRouter
//
//  Created by Oleksii on 17/03/2017.
//  Copyright © 2017 ViolentOctopus. All rights reserved.
//

import Foundation

public typealias Header = (field:String, value:String)

public struct Router<T: EndpointType>: URLRepresentable {
  public let environment: T.Environment
  public let route: T.Route
  
  public init(_ environment: T.Environment = T.current, at route: T.Route) {
      self.environment = environment
      self.route = route
  }
  
  public var components: URLComponents {
      var components = environment.components
      let route = self.route.route
    
      components.path = environment.value.defaultPath.with(route.path).pathValue
      components.queryItems = route.query?.queryItems
      components.fragment = route.fragment
    
      return components
  }
  
  public var request: URLRequest {
    let url     = self.url
    let method  = self.route.method
    let headers = self.route.headers
    var request = URLRequest(url: url)
    
    request.httpMethod = method.rawValue
    
    for header in headers {
      request.addValue(header.value, forHTTPHeaderField: header.field)
    }

    return request

  }
  
  public func request(with cachePolicy:URLRequest.CachePolicy, timeoutInterval: TimeInterval ) -> URLRequest {
    let url     = self.url
    let method  = self.route.method
    let headers = self.route.headers
    var request = URLRequest(url: url, cachePolicy:cachePolicy, timeoutInterval: timeoutInterval)
    
    request.httpMethod = method.rawValue
    
    for header in headers {
      request.addValue(header.value, forHTTPHeaderField: header.field)
    }
    
    return request
  }
}

public protocol URLRepresentable {
  var components: URLComponents { get }
  var url: URL { get }
}

public extension URLRepresentable {
  public var url: URL {
      guard let url = components.url else { fatalError("URL components are not valid") }
      return url
  }
}

public protocol EndpointType {
  associatedtype Environment: EnvironmentType
  associatedtype Route: RouteType
  
  static var current: Environment { get }
  
}

public protocol RouteType {
  var route: URL.Route { get }
  var method: URL.Method { get }
  var headers: [Header] { get }

}

public protocol EnvironmentType: URLRepresentable {
    var value: URL.Env { get }
}

public extension EnvironmentType {
    public var components: URLComponents {
        var components = URLComponents()
        let environment = value
        
        components.scheme = environment.scheme.rawValue
        components.host = environment.host.hostString
        components.port = environment.port
        components.path = environment.defaultPath.pathValue
        
        return components
    }
}
