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
  
//  public var request: URLRequest {
//    let url     = self.url
//    let method  = self.route.method
//    let headers = self.route.headers
//    var request = URLRequest(url: url)
//    
//    request.httpMethod = method.rawValue
//    
//    for header in headers {
//      request.addValue(header.value, forHTTPHeaderField: header.field)
//    }
//
//    return request
//
//  }
  
  public func request(with cachePolicy:URLRequest.CachePolicy = .useProtocolCachePolicy, timeoutInterval: TimeInterval = 500) -> URLRequest {
    let url     = self.url
    let method  = self.route.method
    let headers = self.route.headers
    var request = URLRequest(url: url, cachePolicy:cachePolicy, timeoutInterval: timeoutInterval)
    
    request.httpMethod = method.rawValue
    
    if let body = self.route.body {
      request.httpBody = body
    }
    
    for header in headers {
      request.addValue(header.value, forHTTPHeaderField: header.field)
    }
    
    return request
  }
  
  public func decodeJSON<T: Decodable>(with session: URLSession = URLSession.shared) -> T? {

    var result:T?
    
    if HyperSpace.debug {
      
      result = try? JSONDecoder().decode(T.self, from: self.route.mockResponseData)
      
    } else {
    
      let _ = session.sendSynchronousRequest(with:self.request()) {
        
        (data, response, error) -> Void in
        
        if (error != nil) {
          print(error!)
        } else {
          let httpResponse = response as! HTTPURLResponse
          print(httpResponse)
          
          guard let data = data else { return }
          result = try? JSONDecoder().decode(T.self, from: data)

        }
      }
    }

    return result

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
  var body: Data? { get }
  var mockResponseData: Data { get }
  
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
