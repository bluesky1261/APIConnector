//
//  APIConnector+Request.swift
//  
//
//  Created by Joonghoo Im on 2023/03/04.
//

import Alamofire
import Combine

// MARK: - Request + Combine
extension APIConnector {
    public func request<Model, Parameters>(resource: any APIResource,
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
    
    public func request<Model>(resource: any APIResource,
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
}

// MARK: APIClient + publish
extension APIConnector {
    fileprivate func publish<Model, Parameters>(resource: any APIResource,
                                                model: Model.Type,
                                                parameters: Parameters?,
                                                encoder: ParameterEncoder = JSONParameterEncoder.default) -> DataResponsePublisher<Model> where Model: Decodable, Parameters: Encodable {
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
        .publishDecodable()
    }
}
