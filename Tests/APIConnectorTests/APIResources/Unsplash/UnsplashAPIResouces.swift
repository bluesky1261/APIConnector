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
    
    var headers: HTTPHeaders? {
        let headers = ["client_id": "hb2G6bTs1Jr0gChHCR6-HOUnQt-58aNqZo4wD4mXQVw"]
        return HTTPHeaders(headers)
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
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .topic:
            return .get
        case .photo:
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
