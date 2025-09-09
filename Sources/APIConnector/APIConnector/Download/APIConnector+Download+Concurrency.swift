//
//  APIConnector+Download+Concurrency.swift
//  
//
//  Created by Joonghoo Im on 2022/07/02.
//

import Foundation
import Alamofire

extension APIConnector {
    func download<Parameters>(resource: any APIResource,
                              to destination: DownloadRequest.Destination? = nil,
                              parameters: Parameters,
                              encoder: ParameterEncoder = JSONParameterEncoder.default) async throws -> URL where Parameters: Encodable {
        return try await serializingDownload(resource: resource,
                                             destination: destination,
                                             parameters: parameters,
                                             encoder: encoder)
        .value(resource, statusCode: configuration.validStatusCode)
    }
    
    func download(resource: APIResource,
                  to destination: DownloadRequest.Destination? = nil,
                  encoder: ParameterEncoder = JSONParameterEncoder.default) async throws -> URL {
        let parameters = resource.httpMethod == .get ? nil : EmptyParameters()
        
        return try await serializingDownload(resource: resource,
                                             destination: destination,
                                             parameters: parameters,
                                             encoder: encoder)
        .value(resource, statusCode: configuration.validStatusCode)
    }
}

// MARK: serializingDownload
extension APIConnector {
    fileprivate func serializingDownload<Parameters>(resource: APIResource,
                                                     destination: DownloadRequest.Destination? = nil,
                                                     parameters: Parameters?,
                                                     encoder: ParameterEncoder = JSONParameterEncoder.default) -> DownloadTask<URL> where Parameters: Encodable {
        return makeDownloadRequest(resource: resource, destination: destination, parameters: parameters, encoder: encoder)
            .validate(retriableStatusCode: (configuration.retriableStatusCode), resource: resource, validator: self.validator)
            .serializingDownloadedFileURL()
    }
}
