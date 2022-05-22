//
//  File.swift
//  
//
//  Created by Joonghoo Im on 2022/05/15.
//

import Foundation
import APIConnector
import Alamofire

enum UnsplashAPIResouces: APIResource {
    typealias DecodableErrorType = UnsplashAPIResouces.DecodableError
    
    case topic
    case photo
    case invalidAuthorization
    case invalidEndpoint
    
    var headers: HTTPHeaders? {
        switch self {
        case .invalidAuthorization:
            return nil
        default:
            let httpHeaders = HTTPHeaders(["Authorization" : "Client-ID hb2G6bTs1Jr0gChHCR6-HOUnQt-58aNqZo4wD4mXQVw"])
            return httpHeaders
        }
    }
    
    var baseURL: URL {
        return URL(string: "https://api.unsplash.com")!
    }
    
    var endpoint: String {
        switch self {
        case .topic:
            return "/topics"
        case .photo:
            return "/photos"
        case .invalidAuthorization:
            return "/topics"
        case .invalidEndpoint:
            return "/invalid"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .topic:
            return .get
        case .photo:
            return .get
        case .invalidAuthorization:
            return .get
        case .invalidEndpoint:
            return .get
        }
    }
    
    func decodeError(data: Data) throws -> DecodableError {
        return try decodeError(data: data)
    }
}

extension UnsplashAPIResouces {
    struct DecodableError: APIConnectorErrorDecodable {
        let errors: [String]
        
        var errorMessage: String? {
            return errors.first
        }
    }
}
