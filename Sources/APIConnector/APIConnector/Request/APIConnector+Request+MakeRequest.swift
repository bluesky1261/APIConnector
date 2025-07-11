//
//  File.swift
//  APIConnector
//
//  Created by Joonghoo Im on 11/9/24.
//

extension APIConnector {
    internal func makeDataRequest<Parameters>(resource: APIResource,
                                              parameters: Parameters?,
                                              encoder: ParameterEncoder = JSONParameterEncoder.default) -> DataRequest where Parameters: Encodable {
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
    }
}
