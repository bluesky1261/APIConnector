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
                                headers: headerForRequest,
                                to: destination)
    }
    
    internal func makeDownloadRequest<Parameters>(remoteUrl: URL,
                                                  headers: HTTPHeaders? = nil,
                                                  destination: DownloadRequest.Destination? = nil,
                                                  parameters: Parameters?,
                                                  encoder: ParameterEncoder = URLEncodedFormParameterEncoder.default) -> DownloadRequest where Parameters: Encodable {
        var headerForRequest: HTTPHeaders?
        if let additionalHeaders = headers {
            headerForRequest = additionalHeaders
            self.headers.forEach({ header in
                /// AdditionalHeader에 정의되어 있는 Header값 중, APIClient에 존재하는 값은 APIClient에 있는 기본 값을 무시한다.
                guard headerForRequest?.value(for: header.name) == nil else { return }
                headerForRequest?.add(header)
            })
        } else {
            headerForRequest = self.headers
        }
         
        return session.download(remoteUrl,
                                method: .get,
                                parameters: parameters,
                                encoder: encoder,
                                headers: headerForRequest,
                                to: destination)
     }

}
