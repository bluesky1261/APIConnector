import Foundation
import Alamofire

public struct APIConnector {
    private let configuration: URLSessionConfiguration
    static let validStatusCode: Range<Int> = 200..<400
    
    // MARK: - Public Variables
    public private(set) var session: Session
    public static let shared: APIConnector = APIConnector()
    
    /// APIConnector Initializer
    public init(configuration: URLSessionConfiguration? = nil,
                interceptor: RequestInterceptor? = nil,
                eventMonitors: [EventMonitor] = []) {
        if let configuration = configuration {
            self.configuration = configuration
        } else {
            self.configuration = URLSessionConfiguration.default
            self.configuration.headers = [
                .defaultAcceptEncoding,
                .defaultAcceptLanguage,
                .defaultUserAgent
            ]
        }
        
        self.session = Session(configuration: self.configuration, interceptor: interceptor, eventMonitors: eventMonitors)
    }
    
    /// Cancel All Requests
    public func cancelAllRequests() {
        session.cancelAllRequests()
    }
}
