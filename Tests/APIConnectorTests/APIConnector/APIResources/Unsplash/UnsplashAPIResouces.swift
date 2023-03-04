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
    case topic
    case photo
    case invalidAuthorization
    case invalidEndpoint
    
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
    
    var additionalHeaders: HTTPHeaders? {
        switch self {
        case .invalidAuthorization:
            return nil
        default:
            let httpHeaders = HTTPHeaders(["Authorization" : "Client-ID hb2G6bTs1Jr0gChHCR6-HOUnQt-58aNqZo4wD4mXQVw"])
            return httpHeaders
        }
    }
    
    func decodeError(data: Data) throws -> APIErrorDecodable {
        let decoder = JSONDecoder()
        return try decoder.decode(UnsplashAPIResouces.DecodableError.self, from: data)
    }
}

extension UnsplashAPIResouces {
    struct DecodableError: APIErrorDecodable {
        let errors: [String]
        
        var errorMessage: String? {
            return errors.first
        }
    }
}
