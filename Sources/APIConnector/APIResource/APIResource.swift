//
//  APIResource.swift
//  
//
//  Created by Joonghoo Im on 2022/05/15.
//

import Foundation
import Alamofire

public protocol APIResource {
    associatedtype DecodableErrorType: APIConnectorErrorDecodable
    
    var headers: HTTPHeaders? { get }
    var baseURL: URL { get }
    var endpoint: String { get }
    var httpMethod: HTTPMethod { get }
    
    func decodeError(data: Data) throws -> DecodableErrorType
}

extension APIResource {
    func decodeError(data: Data) throws -> APIConnectorErrorDecodable {
        let decoder = JSONDecoder()
        return try decoder.decode(DecodableErrorType.self, from: data)
    }
}
