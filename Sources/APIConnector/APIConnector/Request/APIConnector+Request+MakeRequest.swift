//
//  File.swift
//  APIConnector
//
//  Created by Joonghoo Im on 11/9/24.
//
import Foundation

extension APIConnector {
    internal func makeDataRequest<Parameters>(resource: APIResource,
                                              parameters: Parameters?,
                                              encoder: ParameterEncoder = JSONParameterEncoder.default) -> DataRequest where Parameters: Encodable {
        let fullURL = Self.makeFullURL(base: resource.baseURL, endpoint: resource.endpoint, queryItems: resource.queryItems)
        let headerForRequest = makeRequestHeader(resource: resource)
        
        var parameterEncoder = encoder
        
        /// QueryItems가 nil이 아닌 경우, URLEncoding은 QueryItem을 통해 + POST 방식인 경우 존재하여 예외로 둠
        if parameters != nil && resource.httpMethod == .get && resource.queryItems == nil {
            parameterEncoder = URLEncodedFormParameterEncoder.default
        }
        
        return session.request(fullURL,
                               method: resource.httpMethod,
                               parameters: parameters,
                               encoder: parameterEncoder,
                               headers: headerForRequest)
    }

    /// URLComponents를 사용하여 URL을 구성합니다.
    /// queryItems가 nil인 경우 기존 appendingPathComponent 동작을 그대로 유지하고,
    /// queryItems가 있는 경우에만 URLComponents 기반으로 URL을 구성하여 쿼리 파라미터를 안전하게 추가합니다.
    internal static func makeFullURL(base: URL, endpoint: String, queryItems: [URLQueryItem]?) -> URL {
        // queryItems가 있는 경우: URLComponents로 URL 구성
        if let queryItems, !queryItems.isEmpty {
            var components = URLComponents()
            components.scheme = base.scheme
            components.host = base.host
            components.port = base.port

            // endpoint가 이미 percent-encoded된 문자를 포함할 수 있으므로
            // percentEncodedPath를 사용하여 이중 인코딩을 방지
            let basePath = base.path
            let fullPath: String
            if endpoint.hasPrefix("/") {
                fullPath = basePath.hasSuffix("/")
                    ? String(basePath.dropLast()) + endpoint
                    : basePath + endpoint
            } else {
                fullPath = basePath.hasSuffix("/")
                    ? basePath + endpoint
                    : basePath + "/" + endpoint
            }
            components.percentEncodedPath = fullPath

            components.queryItems = queryItems

            if let url = components.url {
                return url
            }

            assertionFailure("[APIConnector] URL 생성 실패 - base: \(base), endpoint: \(endpoint)")
        }

        // queryItems가 없거나 URLComponents 생성 실패 시 기존 로직 사용
        return base.appendingPathComponent(endpoint)
    }
}
