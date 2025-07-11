//
//  APIConnector+Request+Concurrency.swift
//  
//
//  Created by Joonghoo Im on 2023/03/04.
//

import Foundation

// MARK: - APIConnector + Request
extension APIConnector {
    public func request<Model, Parameters>(resource: APIResource,
                                           model: Model.Type,
                                           parameters: Parameters,
                                           encoder: ParameterEncoder = JSONParameterEncoder.default) async throws -> Model where Model: Decodable, Parameters: Encodable {
        return try await serializing(resource: resource,
                                     model: model,
                                     parameters: parameters,
                                     encoder: encoder)
        .value(resource, statusCode: configuration.validStatusCode)
    }
    
    public func request<Model>(resource: APIResource,
                               model: Model.Type,
                               encoder: ParameterEncoder = JSONParameterEncoder.default) async throws -> Model where Model: Decodable {
        let parameters = resource.httpMethod == .get ? nil : EmptyParameters()
        return try await serializing(resource: resource,
                                     model: model,
                                     parameters: parameters,
                                     encoder: encoder)
        .value(resource, statusCode: configuration.validStatusCode)
    }
    
    public func requestData<Parameters>(resource: APIResource,
                                        parameters: Parameters,
                                        encoder: ParameterEncoder = JSONParameterEncoder.default) async throws -> Data where Parameters: Encodable {
        return try await serializing(resource: resource,
                                     parameters: parameters,
                                     encoder: encoder)
        .value(resource, statusCode: configuration.validStatusCode)
    }
    
    public func requestData(resource: APIResource,
                            encoder: ParameterEncoder = JSONParameterEncoder.default) async throws -> Data {
        let parameters = resource.httpMethod == .get ? nil : EmptyParameters()
        
        return try await serializing(resource: resource,
                                     parameters: parameters,
                                     encoder: encoder)
        .value(resource, statusCode: configuration.validStatusCode)
    }
}

// MARK: APIConnector + serializing
extension APIConnector {
    fileprivate func serializing<Model, Parameters>(resource: APIResource,
                                                    model: Model.Type,
                                                    parameters: Parameters?,
                                                    encoder: ParameterEncoder = JSONParameterEncoder.default) -> DataTask<Model> where Model: Decodable, Parameters: Encodable {
        return makeDataRequest(resource: resource, parameters: parameters, encoder: encoder)
            .validate(retriableStatusCode: (configuration.retriableStatusCode), resource: resource, validator: self.validator)
            .serializingDecodable()
    }
    
    fileprivate func serializing<Parameters>(resource: APIResource,
                                             parameters: Parameters?,
                                             encoder: ParameterEncoder = JSONParameterEncoder.default) -> DataTask<Data> where Parameters: Encodable {
        return makeDataRequest(resource: resource, parameters: parameters, encoder: encoder)
            .validate(retriableStatusCode: (configuration.retriableStatusCode), resource: resource, validator: self.validator)
            .serializingData()
    }
}
