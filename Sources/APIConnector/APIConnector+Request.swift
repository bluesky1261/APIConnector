//
//  APIConnector+Request.swift
//  
//
//  Created by Joonghoo Im on 2022/05/15.
//

import Foundation
import Alamofire

// MARK: - APIConnector + Request
extension APIConnector {
    public func request<Resource, Request, Response>(resource: Resource,
                                                     parameters: Request,
                                                     responseModel: Response.Type,
                                                     encoder: ParameterEncoder = JSONParameterEncoder.default) async throws
    -> Response where Resource: APIResource, Request: Encodable, Response: Decodable {
        let requestUrl = resource.baseURL.appendingPathComponent(resource.endpoint)
        
        return try await self.session.request(requestUrl, method: resource.httpMethod, parameters: parameters, encoder: encoder, headers: resource.headers)
            .validate(resource: resource)
            .serializingDecodable()
            .value
    }
}

fileprivate extension DataRequest {
    func validate<Resource>(resource: Resource, statusCode: Range<Int> = (200..<400)) async throws -> Self where Resource: APIResource {
        let response = self.response
        /// Timeout 에러 체크
        if let error = self.error, error.isSessionTaskError {
            if (error as NSError).code == NSURLErrorTimedOut {
                throw APIConnectorError.timeout
            } else {
                throw APIConnectorError.unknown(error)
            }
        }
        
        /// Response 여부 체크
        guard let urlResponse = self.response else {
            throw APIConnectorError.noResponse
        }
        
        /// Data 존재 여부 체크
        guard let data = self.data else {
            throw APIConnectorError.noData
        }
        
        /// Status Code 체크
        guard statusCode.contains(urlResponse.statusCode) else {
            if urlResponse.statusCode == 401 {
                throw APIConnectorError.unAuthorized
            }
            
            do {
                let error = try resource.decodeError(data: data)
                throw APIConnectorError.http(error, urlResponse)
            } catch let error {
                throw APIConnectorError.decode(error)
            }
        }
        
        return self
    }
}

// MARK: - DataTask + Value
fileprivate extension DataTask {
    func value<Resource>(resource: Resource, statusCode: Range<Int> = (200..<400)) async throws -> Value where Resource: APIResource {
        let response = await self.response
        
        if let error = response.error, error.isSessionTaskError {
            if (error as NSError).code == NSURLErrorTimedOut {
                throw APIConnectorError.timeout
            } else {
                throw APIConnectorError.unknown(error)
            }
        }
        
        guard let urlResponse = response.response else {
            throw APIConnectorError.noResponse
        }
        
        guard let data = response.data else {
            throw APIConnectorError.noData
        }
        
        guard statusCode.contains(urlResponse.statusCode) else {
            if urlResponse.statusCode == 401 {
                throw APIConnectorError.unAuthorized
            }
            
            do {
                let error = try resource.decodeError(data: data)
                throw APIConnectorError.http(error, urlResponse)
            } catch let error {
                throw APIConnectorError.decode(error)
            }
        }
        
        return try await value
    }
}
