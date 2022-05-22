import Foundation
import Alamofire

public struct APIConnector {
    private let configuration: URLSessionConfiguration
    private(set) var validStatusCode: Range<Int> = 200..<400
    
    // MARK: - Public Variables
    public private(set) var session: Session
    public static let shared: APIConnector = APIConnector()

    /// APIConnector Initializer
    public init(configuration: URLSessionConfiguration? = nil) {
        if let configuration = configuration {
            self.configuration = configuration
            self.session = Session(configuration: configuration)
        } else {
            self.configuration = URLSessionConfiguration.default
            self.configuration.headers = [
                .defaultAcceptEncoding,
                .defaultAcceptLanguage,
                .defaultUserAgent
            ]
            
            self.session = Session(configuration: self.configuration)
        }
    }
    
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
    
    /// Cancel All Requests
    public func cancelAllRequests() {
        session.cancelAllRequests()
    }
}
