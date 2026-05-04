//
//  APIResource.swift
//  
//
//  Created by Joonghoo Im on 2022/05/15.
//
import Foundation

public typealias APIResource = APIBase & APIEndpoint

public protocol APIBase {
    var baseURL: URL { get }
    
    func decodeError(data: Data) throws -> APIErrorDecodable
}

public protocol APIEndpoint {
    var endpoint: String { get }
    var httpMethod: HTTPMethod { get }
    var additionalHeaders: HTTPHeaders? { get }
    
    /// POST 방식 호출시 URL Query Item을 추가적으로 전달해야 할 때 사용하는 값입니다.
    /// 일반적인 경우에는 사용하지 않습니다.
    var queryItems: [URLQueryItem]? { get }
}

// MARK: - Default Implementation
public extension APIEndpoint {
    var queryItems: [URLQueryItem]? { nil }
}
