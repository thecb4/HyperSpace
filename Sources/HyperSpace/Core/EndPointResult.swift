//
//  EndPointResult.swift
//  HyperSpace
//
//  Created by Cavelle Benjamin on 18-Jan-15 (03).
//

import Foundation
import Result

// https://medium.com/@jamesrochabrun/protocol-based-generic-networking-using-jsondecoder-and-decodable-in-swift-4-fc9e889e8081

public struct FutureEndPointResult {
  public let response: URLResponse
  public let data: Data
}

public typealias EndPointDataResult = Result<(Data, URLResponse), AnyError>

public struct EndPointResult {
  public let response: URLResponse?
  public let data: Data?
  public let error: Error?
  
  public init(response: URLResponse?, data: Data?, error: Error?) {
    self.response = response
    self.data     = data
    self.error    = error
  }
}

extension EndPointResult {
  
  public var responseString: Result<String, URL.RouterError> {
    guard let httpResponse = self.response as? HTTPURLResponse else {
      return .failure( .contactFailure(message:"no HTTP response detected") )
    }
    
    return .success(httpResponse.description)
  }
  
  public var httpStatusCode: Result<HTTPStatusCode, URL.RouterError> {

    guard let httpResponse = self.response as? HTTPURLResponse else {
      return .failure( .contactFailure(message:"no HTTP response detected") )
    }
    
    let code = HTTPStatusCode(httpResponse.statusCode)
    
    return .success(code)
  }
  
  public func json<T:Codable>() -> Result<T, URL.ResponseError> {
    guard let data = self.data else { return .failure( .noDataPresent ) }
    guard let result = try? JSONDecoder().decode(T.self, from: data) else { return .failure( .decodeFailure("\(T.self)") ) }
//    let result = try? JSONDecoder().decode(T.self, from: data)
    return .success(result)
  }
  
}

extension Result where Value == (Data,URLResponse) {
  
  public var responseString: Result<String, URL.RouterError> {
    
    switch self {
      case .success(let info):
        let (_,response) = info
        return .success( response.description )
      case .failure(let error):
        return .failure( .contactFailure(message:"bad response \(error.localizedDescription)") )
    }
    
  }
  
  public var httpStatusCode: Result<HTTPStatusCode, URL.RouterError> {
    
    switch self {
      case .success(let info):
        let (_,response) = info
        guard let httpResponse = response as? HTTPURLResponse else {
          return .failure( .contactFailure(message:"no HTTP response detected") )
        }
        return .success ( HTTPStatusCode(httpResponse.statusCode) )
      case .failure(let error):
        return .failure( .contactFailure(message:"bad response \(error.localizedDescription)") )
    }

  }
  
  public func json<T:Codable>() -> Result<T, URL.ResponseError> {
    
    switch self {
      case .success(let info):
        let (data,_) = info
        guard let result = try? JSONDecoder().decode(T.self, from: data) else {
          return .failure( .decodeFailure("\(T.self)") )
        }
        return .success( result )
      case .failure(let error):
        return .failure( .decodeFailure("\(T.self) : \(error.localizedDescription)") )
    }

  }
  
}
