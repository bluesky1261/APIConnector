//
//  UnsplashInterceptor.swift
//  
//
//  Created by Joonghoo Im on 2022/05/23.
//

import Foundation
import APIConnector
import Alamofire

final class UnsplashInterceptor: APIConnectorInterceptor {
    var retryCount: Int = 0
    var targetRetryCount: Int
    
    var retryLimit: Int = 3
    var retryDelay: TimeInterval = 1.0
    
    init(targetRetryCount: Int) {
        self.targetRetryCount = targetRetryCount
    }
    
    func adapt(_ urlRequest: URLRequest, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        if targetRetryCount == retryCount {
            print("* Completing Adapt function...(\(retryCount))")
            var urlRequest = urlRequest
            let header = HTTPHeader(name: "Authorization", value: "Client-ID hb2G6bTs1Jr0gChHCR6-HOUnQt-58aNqZo4wD4mXQVw")
            
            urlRequest.headers.add(header)
            completion(.success(urlRequest))
        } else {
            retryCount += 1
            print("* Retrying Adapt function...(\(retryCount))")
            completion(.success(urlRequest))
        }
    }
    
    func retry(_ urlResponse: HTTPURLResponse, retryCount: Int, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        if retryCount < retryLimit,
           let afError = error as? AFError,
           afError.isResponseValidationError {
            print("* Retrying... Retry function...(\(retryCount))")
            completion(.retryWithDelay(retryDelay))
        } else {
            print("* Completing Retry function...(\(retryCount))")
            completion(.doNotRetry)
        }
    }
}
