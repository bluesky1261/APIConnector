//
//  APIConnector+Request+Concurrency.swift
//  
//
//  Created by Joonghoo Im on 2023/03/04.
//

import Foundation
import Alamofire

// MARK: - APIConnector + Request
extension APIConnector {
    public func request<Model, Parameters>(resource: any APIResource,
                                    model: Model.Type,
                                    parameters: Parameters,
                                    encoder: ParameterEncoder = JSONParameterEncoder.default) async throws -> Model where Model: Decodable, Parameters: Encodable {
        return try await serializing(resource: resource,
                                     model: model,
                                     parameters: parameters,
                                     encoder: encoder)
        .value(resource, statusCode: configuration.validStatusCode)
    }
    
    public func request<Model>(resource: any APIResource,
                        model: Model.Type,
                        encoder: ParameterEncoder = JSONParameterEncoder.default) async throws -> Model where Model: Decodable {
        let parameters = resource.httpMethod == .get ? nil : EmptyParameters()
        return try await serializing(resource: resource,
                                     model: model,
                                     parameters: parameters,
                                     encoder: encoder)
        .value(resource, statusCode: configuration.validStatusCode)
    }
}

// MARK: APIConnector + serializing
extension APIConnector {
    fileprivate func serializing<Model, Parameters>(resource: any APIResource,
                                                    model: Model.Type,
                                                    parameters: Parameters?,
                                                    encoder: ParameterEncoder = JSONParameterEncoder.default) -> DataTask<Model> where Model: Decodable, Parameters: Encodable {
        let fullURL = resource.baseURL.appendingPathComponent(resource.endpoint)
        let headerForRequest = makeRequestHeader(resource: resource)
        
        var parameterEncoder = encoder
        
        if parameters != nil && resource.httpMethod == .get {
            parameterEncoder = URLEncodedFormParameterEncoder.default
        }
        
        return session.request(fullURL,
                               method: resource.httpMethod,
                               parameters: parameters,
                               encoder: parameterEncoder,
                               headers: headerForRequest)
        .validate(retriableStatusCode: (configuration.retriableStatusCode), resource: resource, validator: self.validator)
        .serializingDecodable()
    }
}
