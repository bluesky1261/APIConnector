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
                                                     responseModel: Response.Type,
                                                     parameters: Request,
                                                     encoder: ParameterEncoder = JSONParameterEncoder.default) async throws
    -> Response where Resource: APIResource, Request: Encodable, Response: Decodable {
        let requestUrl = resource.baseURL.appendingPathComponent(resource.endpoint)
        
        return try await self.session.request(requestUrl, method: resource.httpMethod, parameters: parameters, encoder: encoder, headers: resource.headers)
            .validate(statusCode: self.validStatusCode)
            .serializingDecodable()
            .value(resource: resource, statusCode: self.validStatusCode)
    }
}

// MARK: - DataTask + Value
fileprivate extension DataTask {
    func value<Resource>(resource: Resource, statusCode: Range<Int> = (200..<400)) async throws -> Value where Resource: APIResource {
        let response = await self.response
        
        if let error = response.error, error.isSessionTaskError {
            if (error as NSError).code == NSURLErrorTimedOut {
                throw APIConnectorError.unreached
            } else {
                throw APIConnectorError.unknown(error)
            }
        }
        
        guard let data = response.data else {
            throw APIConnectorError.noData
        }
        
        guard let urlResponse = response.response else {
            throw APIConnectorError.noResponse
        }
        
        guard statusCode.contains(urlResponse.statusCode) else {
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
