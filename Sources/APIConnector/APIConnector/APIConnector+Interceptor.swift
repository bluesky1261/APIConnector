//
//  APIConnector+Interceptor.swift
//  
//
//  Created by Joonghoo Im on 2022/05/23.
//

import Alamofire
import Foundation

// MARK: - APIConnectorInterceptorAdaptor
public protocol APIConnectorInterceptorAdaptor {
    func adapt(_ urlRequest: URLRequest,
               completion: @escaping (Result<URLRequest, Error>) -> Void)
}

// MARK: - APIConnectorInterceptorRetrier
public protocol APIConnectorInterceptorRetrier {
    associatedtype APIRetryResult
    
    var retryLimit: Int { get }
    var retryDelay: TimeInterval { get }
    
    func retry(_ urlResponse: HTTPURLResponse,
               retryCount: Int,
               dueTo error: Error,
               completion: @escaping (APIRetryResult) -> Void)
}

// MARK: - APIClientInterceptor
public protocol APIConnectorInterceptor: RequestInterceptor,
                                         APIConnectorInterceptorAdaptor,
                                         APIConnectorInterceptorRetrier where APIRetryResult == Alamofire.RetryResult {}

final class APIClientInterceptorImpl: APIConnectorInterceptor {
    let retryLimit: Int = 3
    let retryDelay: TimeInterval = 1.0
    
    // MARK: APIClientInterceptorAdaptor
    func adapt(_ urlRequest: URLRequest,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        //    if let accessToken = AppCredential.shared.accesssToken {
        //      urlRequest.headers.add(.authorization(bearerToken: accessToken))
        //    }
        
        completion(.success(urlRequest))
    }
    
    // MARK: APIClientInterceptorRetrier
    func retry(_ urlResponse: HTTPURLResponse,
               retryCount: Int,
               dueTo error: Error,
               completion: @escaping (APIRetryResult) -> Void) {
        completion(.doNotRetry)
        //    if retryCount < retryLimit, urlResponse.statusCode == 401 {
        //      Task {
        //        // Retry 로직 수행
        //        do {
        //          try await AppCredential.shared.updateToken()
        //          completion(.retryWithDelay(retryDelay))
        //        } catch let error {
        //          completion(.doNotRetryWithError(error))
        //        }
        //      }
        //    } else {
        //      completion(.doNotRetry)
        //    }
    }
    
    // MARK: Alamofire.RequestAdapter
    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adapt(urlRequest, completion: completion)
    }
    
    // MARK: Alamofire.RequestRetrier
    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        guard let urlResponse = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetry)
            return
        }
        
        retry(urlResponse,
              retryCount: request.retryCount,
              dueTo: error,
              completion: completion)
    }
}
