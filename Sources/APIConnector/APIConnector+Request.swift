//
//  File.swift
//  
//
//  Created by Joonghoo Im on 2022/05/29.
//

import Foundation
import Alamofire

extension APIConnector {
    public func request<Resource, Request, Response>(resource: Resource,
                                                     parameters: Request,
                                                     responseModel: Response.Type,
                                                     encoder: ParameterEncoder = JSONParameterEncoder.default,
                                                     additionalHeader: HTTPHeaders? = nil,
                                                     completion: @escaping (Result<Response, APIConnectorError>) -> Void)
    where Resource: APIResource, Request: Encodable, Response: Decodable {
        let requestUrl = resource.baseURL.appendingPathComponent(resource.endpoint)
        var headers = resource.headers ?? HTTPHeaders()
        additionalHeader?.forEach { headers.add($0)}
        
        self.session.request(requestUrl, method: resource.httpMethod, parameters: parameters, encoder: encoder, headers: headers)
            .validate(retriableStatusCode: 401...401)
            .responseDecodable { (response: DataResponse<Response, AFError>) in
                if let error = response.error {
                    if error.isSessionTaskError, (error as NSError).code == NSURLErrorTimedOut {
                        completion(.failure(.timeout))
                    } else if error.isResponseSerializationError {
                        completion(.failure(.decode(error)))
                    } else if error.isResponseValidationError {
                        completion(.failure(.unAuthorized))
                    }
                }
                
                guard let urlResponse = response.response else {
                    completion(.failure(.noResponse))
                    return
                }
                
                guard let data = response.data else {
                    completion(.failure(.noData))
                    return
                }
                
                guard self.validStatusCode.contains(urlResponse.statusCode) else {
                    do {
                        let decodedError: APIConnectorErrorDecodable = try resource.decodeError(data: data)
                        completion(.failure(.http(decodedError, urlResponse)))
                    } catch let error {
                        completion(.failure(.decode(error)))
                    }
                    return
                }
                
                guard let value = response.value else {
                    completion(.failure(.noData))
                    return
                }
                
                completion(.success(value))
            }
    }
}
