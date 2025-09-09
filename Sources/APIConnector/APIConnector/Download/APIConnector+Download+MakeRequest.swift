//
//  File.swift
//  APIConnector
//
//  Created by john.f on 9/9/25.
//

import Foundation

extension APIConnector {
    internal func makeDownloadRequest<Parameters>(resource: APIResource,
                                                 destination: DownloadRequest.Destination? = nil,
                                                 parameters: Parameters?,
                                                 encoder: ParameterEncoder = JSONParameterEncoder.default) -> DownloadRequest where Parameters: Encodable {
        let fullURL = resource.baseURL.appendingPathComponent(resource.endpoint)
        let headerForRequest = makeRequestHeader(resource: resource)
        
        var parameterEncoder = encoder
        
        if parameters != nil && resource.httpMethod == .get {
            parameterEncoder = URLEncodedFormParameterEncoder.default
        }
        
        return session.download(fullURL,
                                method: resource.httpMethod,
                                parameters: parameters,
                                encoder: parameterEncoder,
                                headers: headers,
                                to: destination)
    }

}
