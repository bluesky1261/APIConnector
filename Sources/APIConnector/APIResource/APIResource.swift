//
//  APIResource.swift
//  
//
//  Created by Joonghoo Im on 2022/05/15.
//

import Foundation
import Alamofire

public protocol APIResource {
    var baseURL: URL { get }
    var endpoint: String { get }
    var httpMethod: HTTPMethod { get }
    var additionalHeaders: HTTPHeaders? { get }
    
    func decodeError(data: Data) throws -> APIErrorDecodable
}
