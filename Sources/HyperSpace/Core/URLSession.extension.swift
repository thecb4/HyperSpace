//
//  URLSession.extension.swift
//  HyperSpace
//
//  Created by Cavelle Benjamin on 18-Jan-02 (01).
//

import Foundation

#if os(Linux)
  import Glibc
  import Dispatch
#endif


extension URLSession {
  
  func sendSynchronousRequest(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
    
    let semaphore = DispatchSemaphore(value: 0)
    
    let task = self.dataTask(with: request) { (data, response, error) in
      
      completionHandler(data,response,error)
      
      semaphore.signal()
      
    }
    
    task.resume()
    
    _ = semaphore.wait(timeout: .distantFuture)
    
  }
  
  
  func sendAsynchronousRequest(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    
    let task = self.dataTask(with: request) { data, response, error in
      
      completionHandler(data, response, error)
      
    }
    
    task.resume()
    
    return task
    
  }
  
}

//
//  URLSession.swift
//  Example
//
//  Created by Thomas Visser on 23/12/14.
//  Copyright (c) 2014 Thomas Visser. All rights reserved.
//

import Foundation
import BrightFutures

extension URLSession {
  
  public typealias DataTaskResult            = (Data?, URLResponse?)
  public typealias UploadTaskResult          = (Data?, URLResponse?)
  public typealias DownloadTaskResult        = (URL?, URLResponse?)
  
  public typealias FutureSessionDataTask     = (URLSessionDataTask, Future<DataTaskResult, AnyError>)
  public typealias FutureSessionUploadTask   = (URLSessionUploadTask, Future<DataTaskResult, AnyError>)
  public typealias FutureSessionDownloadTask = (URLSessionDownloadTask, Future<DownloadTaskResult, AnyError>)
  
  open func dataTask(with request: URLRequest) -> FutureSessionDataTask {
    let p = Promise<DataTaskResult, AnyError>()
    
    let task = self.dataTask(with: request, completionHandler: self.completionHandler(promise: p))
    
    return (task, p.future)
  }
  
  open func dataTask(with url: URL) -> FutureSessionDataTask {
    let p = Promise<DataTaskResult, AnyError>()
    
    let task = self.dataTask(with: url, completionHandler: self.completionHandler(promise: p))
    
    return (task, p.future)
  }
  
  
  open func uploadTask(with request: URLRequest, fromFile fileURL: URL) -> FutureSessionUploadTask {
    let p = Promise<DataTaskResult, AnyError>()
    
    let task = self.uploadTask(with: request, fromFile: fileURL as URL, completionHandler: self.completionHandler(promise: p))
    
    return (task, p.future)
  }
  
  
  open func uploadTask(with request: URLRequest, from bodyData: Data?) -> FutureSessionUploadTask {
    let p = Promise<DataTaskResult, AnyError>()
    
    let task = self.uploadTask(with: request, from: bodyData, completionHandler: self.completionHandler(promise: p))
    
    return (task, p.future)
  }
  
  open func downloadTask(with request: URLRequest) -> FutureSessionDownloadTask {
    let p = Promise<DownloadTaskResult, AnyError>()
    
    let task = self.downloadTask(with: request, completionHandler: self.downloadTaskCompletionHandler(promise: p))
    
    return (task, p.future)
  }
  
  open func downloadTask(with url: URL) -> FutureSessionDownloadTask {
    let p = Promise<DownloadTaskResult, AnyError>()
    
    let task = self.downloadTask(with:url, completionHandler: self.downloadTaskCompletionHandler(promise: p))
    
    return (task, p.future)
  }
  
  open func downloadTask(withResumeData resumeData: Data) -> FutureSessionDownloadTask {
    let p = Promise<DownloadTaskResult, AnyError>()
    
    let task = self.downloadTask(withResumeData: resumeData, completionHandler: self.downloadTaskCompletionHandler(promise: p))
    
    return (task, p.future)
  }
  
  
  open func completionHandler(promise p: Promise<DataTaskResult, AnyError>) -> (Data?, URLResponse?, Error?) -> Void {
    return { (data, response, error) -> () in
      if let error = error {
        p.failure(AnyError(cause: error))
      } else {
        p.success((data, response))
      }
    }
  }
  
  open func downloadTaskCompletionHandler(promise p: Promise<DownloadTaskResult, AnyError>) -> (URL?, URLResponse?, Error?) -> Void {
    return { (url, response, error) -> () in
      if let error = error {
        p.failure(AnyError(cause: error))
      } else {
        p.success((url, response))
      }
    }
  }
  
}
