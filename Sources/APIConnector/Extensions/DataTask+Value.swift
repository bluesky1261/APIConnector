//
//  DataTask+Value.swift
//  
//
//  Created by Joonghoo Im on 2022/05/22.
//

import Foundation
import Alamofire

// MARK: - DataTask
extension DataTask {
    public func value<Resource>(resource: Resource, statusCode: Range<Int> = (200..<400)) async throws -> Value where Resource: APIResource {
        let response = await self.response
        
        if let error = response.error {
            if error.isSessionTaskError, (error as NSError).code == NSURLErrorTimedOut {
                throw APIConnectorError.timeout
            } else if error.isResponseSerializationError {
                throw APIConnectorError.decode(error)
            } else if error.isResponseValidationError {
                throw APIConnectorError.unAuthorized
            }
        }
        
        guard let urlResponse = response.response else {
            throw APIConnectorError.noResponse
        }
        
        guard let data = response.data else {
            throw APIConnectorError.noData
        }
        
        guard statusCode.contains(urlResponse.statusCode) else {
            var decodedError: APIConnectorErrorDecodable?
            do {
                decodedError = try resource.decodeError(data: data)
            } catch let error {
                throw APIConnectorError.decode(error)
            }
            
            guard let decodedError = decodedError else {
                throw APIConnectorError.unknown()
            }
            throw APIConnectorError.http(decodedError, urlResponse)
        }
        
        return try await value
    }
}
