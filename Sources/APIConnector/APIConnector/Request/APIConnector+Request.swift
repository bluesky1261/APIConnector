//
//  APIConnector+Request.swift
//  
//
//  Created by Joonghoo Im on 2023/03/04.
//

import Foundation
import Combine

// MARK: - Request + Combine
extension APIConnector {
    public func request<Model, Parameters>(resource: APIResource,
                                           model: Model.Type,
                                           parameters: Parameters,
                                           encoder: ParameterEncoder = JSONParameterEncoder.default) -> AnyPublisher<Model, Error> where Model: Decodable, Parameters: Encodable {
        return self.publish(resource: resource,
                            model: model,
                            parameters: parameters,
                            encoder: encoder)
        .value(resource, statusCode: configuration.validStatusCode)
        .eraseToAnyPublisher()
    }
    
    public func request<Model>(resource: APIResource,
                               model: Model.Type,
                               encoder: ParameterEncoder = JSONParameterEncoder.default) -> AnyPublisher<Model, Error> where Model: Decodable {
        let parameters = resource.httpMethod == .get ? nil : EmptyParameters()
        return self.publish(resource: resource,
                            model: model,
                            parameters: parameters,
                            encoder: encoder)
        .value(resource, statusCode: configuration.validStatusCode)
        .eraseToAnyPublisher()
    }
    
    public func requestData<Parameters>(resource: APIResource,
                                           parameters: Parameters,
                                           encoder: ParameterEncoder = JSONParameterEncoder.default) -> AnyPublisher<Data, Error> where Parameters: Encodable {
        return self.publish(resource: resource,
                            parameters: parameters,
                            encoder: encoder)
        .value(resource, statusCode: configuration.validStatusCode)
        .eraseToAnyPublisher()
    }
    
    public func requestData(resource: APIResource,
                               encoder: ParameterEncoder = JSONParameterEncoder.default) -> AnyPublisher<Data, Error> {
        let parameters = resource.httpMethod == .get ? nil : EmptyParameters()
        return self.publish(resource: resource,
                            parameters: parameters,
                            encoder: encoder)
        .value(resource, statusCode: configuration.validStatusCode)
        .eraseToAnyPublisher()
    }
}

// MARK: APIClient + publish
extension APIConnector {
    fileprivate func publish<Model, Parameters>(resource: APIResource,
                                             model: Model.Type,
                                             parameters: Parameters?,
                                             encoder: ParameterEncoder = JSONParameterEncoder.default) -> DataResponsePublisher<Model> where Model: Decodable, Parameters: Encodable {
        return makeDataRequest(resource: resource,
                               parameters: parameters,
                               encoder: encoder)
        .validate(retriableStatusCode: (configuration.retriableStatusCode), resource: resource, validator: self.validator)
        .publishDecodable()
    }
    
    fileprivate func publish<Parameters>(resource: APIResource,
                                      parameters: Parameters?,
                                      encoder: ParameterEncoder = JSONParameterEncoder.default) -> DataResponsePublisher<Data> where Parameters: Encodable {
        return makeDataRequest(resource: resource,
                               parameters: parameters,
                               encoder: encoder)
        .validate(retriableStatusCode: (configuration.retriableStatusCode), resource: resource, validator: self.validator)
        .publishData()
    }
}
