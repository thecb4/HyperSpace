//
//  Data.extensions.swift
//  HyperSpace
//
//  Created by Cavelle Benjamin on 18-Apr-06 (14).
//

import Foundation
import Result

extension Data {
  
  public enum DecodeError: Error {
    case decodeFailed(`for`: String)
  }
  
  public func jsonResult<Value: Codable>() -> Result<Value, DecodeError> {
    
    let optional = try? JSONDecoder().decode(Value.self, from: self)
    
    guard let value = optional else {
      return .failure(.decodeFailed(for: String(describing: Value.self)))
    }
    
    return .success(value)
    
  }
  
  public func stringResult() -> Result<String, DecodeError> {
    
    guard let info = String(data: self, encoding: .utf8) else {
      return .failure( DecodeError.decodeFailed(for:String(describing: self)) )
    }
    
    return .success(info)
    
  }
  
}
