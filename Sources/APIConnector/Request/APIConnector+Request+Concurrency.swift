//
//  APIConnector+Request+Concurrency.swift
//  
//
//  Created by Joonghoo Im on 2022/05/29.
//

import Foundation
import Alamofire

extension APIConnector {
    public func request<Resource, Request, Response>(resource: Resource,
                                                     parameters: Request,
                                                     responseModel: Response.Type,
                                                     encoder: ParameterEncoder = JSONParameterEncoder.default,
                                                     additionalHeader: HTTPHeaders? = nil) async throws
    -> Response where Resource: APIResource, Request: Encodable, Response: Decodable {
        let requestUrl = resource.baseURL.appendingPathComponent(resource.endpoint)
        var headers = resource.headers ?? HTTPHeaders()
        additionalHeader?.forEach { headers.add($0) }
        
        return try await self.session.request(requestUrl, method: resource.httpMethod, parameters: parameters, encoder: encoder, headers: headers)
            .validate(retriableStatusCode: 401...401)
            .serializingDecodable()
            .value(resource: resource)
    }
}
