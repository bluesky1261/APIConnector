//
//  APIConnector+Interceptor.swift
//  
//
//  Created by Joonghoo Im on 2022/05/23.
//

import Foundation
import Alamofire

// MARK: - APIClientAdaptor Protocol
public protocol APIConnectorAdaptor: RequestAdapter {
    func adapt(_ urlRequest: URLRequest,
               completion: @escaping (Result<URLRequest, Error>) -> Void)
}

// MARK: - APIClientRetrier Protocol
public protocol APIConnectorRetrier: RequestRetrier {
    var retryLimit: Int { get }
    var retryDelay: TimeInterval { get }
    
    func retry(_ urlResponse: HTTPURLResponse,
               retryCount: Int,
               dueTo error: Error,
               completion: @escaping (Alamofire.RetryResult) -> Void)
}

// MARK: - APIConnectorInterceptor Protocol
public protocol APIConnectorInterceptor: RequestInterceptor, APIConnectorAdaptor, APIConnectorRetrier { }

// MARK: - Fileprivate Extension
public extension APIConnectorInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adapt(urlRequest, completion: completion)
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let urlResponse = request.task?.response as? HTTPURLResponse else { return }
        
        retry(urlResponse, retryCount: request.retryCount, dueTo: error, completion: completion)
    }
}
