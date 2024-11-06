//
//  APIResource.swift
//  
//
//  Created by Joonghoo Im on 2022/05/15.
//

import Foundation
import Alamofire

public typealias APIResource = APIBase & APIEndpoint

public protocol APIBase {
    var baseURL: URL { get }
    
    func decodeError(data: Data) throws -> APIErrorDecodable
}

public protocol APIEndpoint {
    var endpoint: String { get }
    var httpMethod: HTTPMethod { get }
    var additionalHeaders: HTTPHeaders? { get }
}
